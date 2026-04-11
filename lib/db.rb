# lib/db.rb — database helpers for the notebook Sinatra app
require 'sqlite3'
require 'cgi'

TAG        = '#:[0-9_a-zA-Z-]+'          # full keyword pattern (no capture)
TAG_CAP    = /#:([0-9_a-zA-Z-]+)/        # keyword with capture group for the word part

APP_ROOT   = File.expand_path('..', __dir__)
NOTEBOOK_DB = File.join(APP_ROOT, 'db', 'notebook_1.db')
AUTH_DB     = File.join(APP_ROOT, 'auth', 'db', 'auth1.db')

def open_db
  db = SQLite3::Database.new(NOTEBOOK_DB)
  db.results_as_hash = true
  # Register REGEXP function so SQLite can use it in queries.
  # Ruby Regexp honours inline flags like (?i:...) from PHP's preg_replace.
  db.create_function('regexp', -1) do |func, *args|
    pattern, string = args[0].to_s, args[1].to_s
    func.result = string.match?(Regexp.new(pattern)) ? 1 : 0
  rescue RegexpError
    func.result = 0
  end
  db
end

def open_auth_db
  db = SQLite3::Database.new(AUTH_DB)
  db.results_as_hash = true
  # Migrate: add rate-limiting columns when they don't exist yet
  cols = db.execute('PRAGMA table_info(users)').map { |r| r['name'] }
  unless cols.include?('failed_attempts')
    db.execute('ALTER TABLE users ADD COLUMN failed_attempts INTEGER NOT NULL DEFAULT 0')
  end
  unless cols.include?('lockout_until')
    db.execute('ALTER TABLE users ADD COLUMN lockout_until DATETIME DEFAULT NULL')
  end
  db
end

# Remove all keyword_links for an article (call before re-indexing body).
def db_delete_keywords(db, a_id)
  db.execute('DELETE FROM keyword_links WHERE a_id = ?', a_id.to_i)
end

# Parse #:keyword tags from body and insert into keywords + keyword_links tables.
def db_add_keywords(db, a_id, body)
  body.scan(Regexp.new(TAG)).each do |keyword|
    # keyword is the full "#:word" string
    row = db.get_first_row('SELECT k_id FROM keywords WHERE keyword = ?', keyword)
    k_id = if row.nil?
      db.execute('INSERT INTO keywords (keyword) VALUES (?)', keyword)
      db.last_insert_row_id
    else
      row['k_id']
    end
    db.execute('INSERT INTO keyword_links (k_id, a_id) VALUES (?, ?)', [k_id, a_id.to_i])
  end
end

def db_add_link(db, a_id_1, a_id_2)
  db.execute('INSERT INTO article_links (a_id_1, a_id_2) VALUES (?, ?)',
             [a_id_1.to_i, a_id_2.to_i])
end

def db_delete_link(db, al_id)
  db.execute('DELETE FROM article_links WHERE al_id = ?', al_id.to_i)
end

# Detect MIME type from file magic bytes.
def detect_mime(path)
  magic = File.open(path, 'rb') { |f| f.read(8).to_s }
  return 'image/jpeg'              if magic.start_with?("\xFF\xD8\xFF")
  return 'image/png'               if magic.start_with?("\x89PNG\r\n\x1A\n")
  return 'application/zip'         if magic.start_with?("PK\x03\x04")
  return 'application/x-bzip2'     if magic.start_with?('BZh')
  return 'application/gzip'        if magic.start_with?("\x1F\x8B")
  return 'application/vnd.ms-excel' if magic.start_with?("\xD0\xCF\x11\xE0")
  # SVG is XML/text — check first 512 bytes for markers
  head = File.open(path, 'rb') { |f| f.read(512).to_s }
  return 'image/svg+xml' if head =~ /<svg/i || head =~ /\A\s*<\?xml/
  'application/octet-stream'
end

# Build the two-column navigator HTML string.
# a_id:            currently displayed article id (for scroll anchors)
# search_keyword:  active keyword filter (without "#:", e.g. "ruby")
# search_title:    active title filter string
def db_navigator(db, a_id: nil, search_keyword: nil, search_title: nil)
  buf = +'<nav>'

  # ── Chronological index ────────────────────────────────────────────────────
  buf << '<b>Chronological Index</b>'
  buf << "<nav_daily id='id_nav_daily'><ul class='index'>"
  db.execute("SELECT * FROM articles WHERE (a_status % 4)=0 ORDER BY a_id DESC") do |row|
    ref = row['a_id'] == a_id ? " id='id_nav_daily_#{a_id}'" : ''
    buf << format("<li%s><a href='/?a_id=%d'>%04d %s %s</a></li>\n",
                  ref, row['a_id'], row['a_id'],
                  CGI.escapeHTML(row['a_datetime'].to_s[0, 10]),
                  CGI.escapeHTML(row['a_title'].to_s))
  end
  buf << "</ul></nav_daily><br>\n"

  # ── Pinned index ───────────────────────────────────────────────────────────
  buf << "<b>Pinned</b><nav_pinned><ul class='index'>\n"
  db.execute("SELECT * FROM articles WHERE (a_status % 4)=1 ORDER BY a_id DESC") do |row|
    ref = row['a_id'] == a_id ? " id='id_nav_pinned_#{a_id}'" : ''
    buf << format("<li%s><a href='/?a_id=%d'>%04d %s %s</a></li>\n",
                  ref, row['a_id'], row['a_id'],
                  CGI.escapeHTML(row['a_datetime'].to_s[0, 10]),
                  CGI.escapeHTML(row['a_title'].to_s))
  end
  buf << "</ul></nav_pinned><br>\n"

  # ── Deleted index ──────────────────────────────────────────────────────────
  buf << "<nav_deleted><details><summary><b>Deleted</b></summary>\n"
  db.execute("SELECT * FROM articles WHERE (a_status % 4)>=2 ORDER BY a_id DESC") do |row|
    title = "<del>#{CGI.escapeHTML(row['a_title'].to_s)}</del>"
    buf << format("<div class='detail_item'><a href='/?a_id=%d'>%04d %s %s</a></div>\n",
                  row['a_id'], row['a_id'],
                  CGI.escapeHTML(row['a_datetime'].to_s[0, 10]), title)
  end
  buf << "</details></nav_deleted>\n</nav>\n"

  # ── Tag (keyword) column ───────────────────────────────────────────────────
  buf << "<col_tag>\n<b>tags</b><nav_keywords>\n"
  kw_sql = "SELECT keyword FROM keywords ORDER BY " \
            "CASE WHEN keyword GLOB '[A-Za-z]*' THEN keyword ELSE '~' || keyword END COLLATE NOCASE"
  db.execute(kw_sql) do |krow|
    keyword        = krow['keyword']                     # e.g. "#:ruby"
    kw_bare        = keyword[2..]                        # e.g. "ruby"
    active         = search_keyword && "#:#{search_keyword}" == keyword
    kbuf           = []                                  # buffer so we can patch the <details> tag
    details_ix     = 0
    kbuf << (active ? "<details open id='id_nav_keyword_s'><summary>\n" \
                    : "<details><summary>\n")
    kbuf << "<a href='/?search_keyword=#{CGI.escape(kw_bare)}'> #{CGI.escapeHTML(keyword)} </a></summary>\n"

    db.execute(
      "SELECT * FROM articles a WHERE a.a_id IN " \
      "(SELECT kl.a_id FROM keyword_links kl WHERE kl.k_id IN " \
      "(SELECT k.k_id FROM keywords k WHERE k.keyword = ?))", keyword
    ) do |arow|
      if arow['a_id'] == a_id
        kbuf[details_ix] = "<details open id='id_nav_keyword_#{a_id}'><summary>\n"
      end
      kbuf << "<div class='detail_item'>"
      kbuf << format("<a href='/?a_id=%d'>%04d %s %s</a>\n",
                     arow['a_id'], arow['a_id'],
                     CGI.escapeHTML(arow['a_datetime'].to_s[0, 10]),
                     CGI.escapeHTML(arow['a_title'].to_s))
      kbuf << "</div>\n"
    end
    kbuf << "</details>\n"
    buf << kbuf.join
  end
  buf << "</nav_keywords>\n"

  # ── Title column ───────────────────────────────────────────────────────────
  buf << "<br><b>titles</b><nav_titles><ul class='index'>\n"
  title_sql = "SELECT * FROM articles WHERE a_title IN " \
              "(SELECT DISTINCT a_title FROM articles) " \
              "ORDER BY CASE WHEN a_title GLOB '[A-Za-z]*' THEN a_title ELSE '~' || a_title END COLLATE NOCASE"

  tbuf       = []
  last_title = nil
  first_grp  = true
  details_ix = nil

  db.execute(title_sql) do |row|
    a_title = row['a_title']
    if a_title != last_title
      tbuf << "</details>\n" unless first_grp   # close previous group
      first_grp = false
      active = search_title && search_title == a_title
      details_ix = tbuf.length
      tbuf << (active ? "<details open id='id_nav_title_s'><summary>" \
                      : "<details><summary>")
      tbuf << "<a href='/?search_title=#{CGI.escape(a_title.to_s)}'> #{CGI.escapeHTML(a_title.to_s)} </a></summary>\n"
      last_title = a_title
    end
    if row['a_id'] == a_id
      tbuf[details_ix] = "<details open id='id_nav_title_#{a_id}'><summary>"
    end
    tbuf << format("<div class='detail_item'><a href='/?a_id=%d'>%04d %s %s</a></div>\n",
                   row['a_id'], row['a_id'],
                   CGI.escapeHTML(row['a_datetime'].to_s[0, 10]),
                   CGI.escapeHTML(a_title.to_s))
  end
  tbuf << "</details>\n" unless first_grp
  buf << tbuf.join
  buf << "</ul></nav_titles>\n</col_tag>\n"

  buf
end
