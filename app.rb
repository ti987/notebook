# app.rb — Sinatra notebook application
# Converts the PHP notebook to Ruby/Sinatra.
# Works standalone (ruby app.rb) or behind Apache reverse proxy.
#
# Run:
#   ruby app.rb                          # development, port 4567
#   REQUIRE_HTTPS=true ruby app.rb       # enforce HTTPS redirect
#   rackup config.ru -p 4567            # via Rack

require 'sinatra'
require 'sinatra/base'
require 'rack'
require 'securerandom'
require 'cgi'
require 'time'
require 'bcrypt'
require_relative 'lib/db'

# ── Timezone (matches PHP date_default_timezone_set("America/Denver")) ──────
ENV['TZ'] = 'America/Denver'

# ── Static files served from the notebook root (css/, js/, images/) ─────────
set :public_folder, File.dirname(__FILE__)
set :views,         File.join(File.dirname(__FILE__), 'views')

# ── Sessions ─────────────────────────────────────────────────────────────────
use Rack::Session::Cookie,
  key:      'nb_session',
  path:     '/',
  httponly: true,
  secure:   (ENV['RACK_ENV'] == 'production'),
  same_site: :strict,
  secret:   ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

# ── Security headers + optional HTTPS redirect ───────────────────────────────
before do
  headers \
    'X-Frame-Options'           => 'DENY',
    'X-Content-Type-Options'    => 'nosniff',
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
    'Referrer-Policy'           => 'same-origin'

  if ENV['REQUIRE_HTTPS'] == 'true'
    https = request.secure? || request.env['HTTP_X_FORWARDED_PROTO'] == 'https'
    unless https
      redirect "https://#{request.host}#{request.fullpath}"
    end
  end
end

# ── Helpers ───────────────────────────────────────────────────────────────────
helpers do
  # HTML-escape a value for safe output in templates.
  def h(text)
    CGI.escapeHTML(text.to_s)
  end

  def require_login
    unless session[:loggedin]
      redirect '/auth/login'
    end
  end

  def csrf_token
    session[:csrf_token] ||= SecureRandom.hex(32)
  end

  def verify_csrf!
    token = params[:csrf_token].to_s
    unless token.length > 0 && Rack::Utils.secure_compare(session[:csrf_token].to_s, token)
      halt 403, 'Invalid request.'
    end
  end

  # Inline JS for scrolling the nav panels to the current article.
  def jump_nav_js
    <<~JS
      <script>
      function jump_nav(id1, id2, id3) {
        if (id1) {
          var e = document.getElementById("id_nav_daily_" + id1);
          if (e) e.scrollIntoView();
          e = document.getElementById("id_nav_title_" + id1);
          if (e) e.scrollIntoView();
          e = document.getElementById("id_nav_keyword_" + id1);
          if (e) e.scrollIntoView();
        }
        if (id2) {
          var e = document.getElementById("id_nav_keyword_s");
          if (e) e.scrollIntoView();
        }
        if (id3) {
          var e = document.getElementById("id_nav_title_s");
          if (e) e.scrollIntoView();
        }
      }
      </script>
    JS
  end
end

# ═══════════════════════════════════════════════════════════════════════════════
# AUTH ROUTES
# ═══════════════════════════════════════════════════════════════════════════════

get '/auth/login' do
  # Already logged in → go home
  redirect '/' if session[:loggedin]
  @csrf_token   = csrf_token
  @login_err    = ''
  @username     = ''
  @username_err = ''
  @password_err = ''
  erb :login
end

post '/auth/login' do
  redirect '/' if session[:loggedin]

  verify_csrf!

  @csrf_token   = csrf_token
  @login_err    = ''
  @username     = params[:username].to_s.strip
  @username_err = ''
  @password_err = ''
  password      = params[:password].to_s.strip

  if @username.empty?
    @username_err = 'Please enter username.'
  end
  if password.empty?
    @password_err = 'Please enter your password.'
  end

  if @username_err.empty? && @password_err.empty?
    db  = open_auth_db
    row = db.get_first_row(
      'SELECT id, username, password, failed_attempts, lockout_until FROM users WHERE username = ?',
      @username
    )

    if row
      locked_until = row['lockout_until']
      if locked_until && Time.parse(locked_until) > Time.now
        @login_err = 'Too many failed attempts. Please try again later.'
      elsif BCrypt::Password.new(row['password']) == password
        # Success — reset counter, start session
        db.execute('UPDATE users SET failed_attempts = 0, lockout_until = NULL WHERE id = ?', row['id'])
        session.clear
        session[:loggedin]   = true
        session[:id]         = row['id']
        session[:username]   = row['username']
        session[:csrf_token] = SecureRandom.hex(32)
        db.close
        redirect '/'
      else
        new_attempts = row['failed_attempts'].to_i + 1
        if new_attempts >= 5
          lockout = (Time.now + 15 * 60).strftime('%Y-%m-%d %H:%M:%S')
          db.execute('UPDATE users SET failed_attempts = ?, lockout_until = ? WHERE id = ?',
                     [new_attempts, lockout, row['id']])
        else
          db.execute('UPDATE users SET failed_attempts = ?, lockout_until = NULL WHERE id = ?',
                     [new_attempts, row['id']])
        end
        @login_err = 'Invalid username or password.'
      end
    else
      @login_err = 'Invalid username or password.'
    end
    db.close
  end

  erb :login
end

get '/auth/logout' do
  session.clear
  redirect '/auth/login'
end

# ═══════════════════════════════════════════════════════════════════════════════
# INDEX (view articles)
# ═══════════════════════════════════════════════════════════════════════════════

get '/' do
  require_login
  @csrf_token      = csrf_token
  @a_id            = params[:a_id]            ? params[:a_id].to_i            : nil
  @search_keyword  = params[:search_keyword]  ? params[:search_keyword]        : nil
  @search_title    = params[:search_title]    ? params[:search_title]           : nil
  @search_text     = params[:search_text]     ? params[:search_text]            : nil

  db = open_db
  @navigator = db_navigator(db,
    a_id:           @a_id,
    search_keyword: @search_keyword,
    search_title:   @search_title
  )

  if @search_text
    pat  = "(?i:#{@search_text})"
    @articles = db.execute(
      "SELECT * FROM articles WHERE (a_title REGEXP ?) OR (a_body REGEXP ?)" \
      " OR (a_mod_date REGEXP ?) OR (a_datetime REGEXP ?) ORDER BY a_id DESC",
      [pat, pat, pat, pat]
    )
  elsif @search_keyword
    keyword   = "#:#{@search_keyword}"
    @articles = db.execute(
      "SELECT * FROM articles a WHERE a.a_id IN " \
      "(SELECT kl.a_id FROM keyword_links kl WHERE kl.k_id IN " \
      "(SELECT k.k_id FROM keywords k WHERE k.keyword = ?)) ORDER BY a.a_id DESC", keyword
    )
  elsif @search_title
    @articles = db.execute('SELECT * FROM articles WHERE a_title = ? ORDER BY a_id DESC', @search_title)
  elsif @a_id
    @articles = db.execute('SELECT * FROM articles WHERE a_id = ?', @a_id)
  else
    @articles = db.execute('SELECT * FROM articles ORDER BY a_id DESC LIMIT 1')
  end

  # Build links list for each displayed article
  @article_links = {}
  @articles.each do |row|
    cur = row['a_id'].to_i
    @article_links[cur] = db.execute(
      "SELECT a_id_2 AS 'a_id' FROM article_links WHERE a_id_1 = ? " \
      "UNION SELECT a_id_1 AS 'a_id' FROM article_links WHERE a_id_2 = ?",
      [cur, cur]
    )
  end

  db.close
  erb :index
end

# ═══════════════════════════════════════════════════════════════════════════════
# ADD ARTICLE
# ═══════════════════════════════════════════════════════════════════════════════

get '/add' do
  require_login
  @csrf_token = csrf_token
  @follow     = params[:follow_up] ? params[:follow_up].to_i : nil
  @follow_row = nil
  @follow_keywords = ''
  @error      = nil

  db = open_db
  if @follow && @follow > 0
    @follow_row = db.get_first_row('SELECT * FROM articles WHERE a_id = ?', @follow)
    if @follow_row
      @follow_keywords = @follow_row['a_body'].to_s.scan(Regexp.new(TAG)).join(' ')
    end
  end
  @navigator = db_navigator(db, a_id: @follow)
  db.close
  erb :add
end

post '/add' do
  require_login

  if params[:cancel]
    redirect '/'
  end

  verify_csrf!

  article1 = params[:article1].to_s
  title1   = params[:title1].to_s

  if article1.empty?
    # Form submitted with empty body — re-render
    @csrf_token = csrf_token
    @follow     = params[:link1] ? params[:link1].to_i : nil
    @follow_row = nil
    @follow_keywords = ''
    db = open_db
    @navigator = db_navigator(db)
    db.close
    @error = 'Title and article can not be empty'
    return erb :add
  end

  title = CGI.escapeHTML(title1).strip
  body  = CGI.escapeHTML(article1)

  if title.empty? || body.strip.empty?
    @csrf_token = csrf_token
    @follow     = nil
    @follow_row = nil
    @follow_keywords = ''
    db = open_db
    @navigator = db_navigator(db)
    db.close
    @error = 'Title and article can not be empty'
    return erb :add
  end

  db      = open_db
  datestr = Time.now.strftime('%Y-%m-%d %H:%M')
  db.execute(
    "INSERT INTO articles (a_datetime, a_title, a_body, a_mod_date) VALUES (?, ?, ?, '')",
    [datestr, title, body]
  )
  a_id = db.last_insert_row_id

  db_add_keywords(db, a_id, body)

  if params[:link1] && !params[:link1].to_s.empty?
    db_add_link(db, a_id, params[:link1].to_i)
  end

  db.close
  redirect '/'
end

# ═══════════════════════════════════════════════════════════════════════════════
# EDIT ARTICLE
# ═══════════════════════════════════════════════════════════════════════════════

get '/edit' do
  require_login
  a_id = params[:a_id].to_i
  halt 400, '?!' if a_id < 1

  @csrf_token = csrf_token
  @a_id       = a_id
  db          = open_db

  @row = db.get_first_row('SELECT * FROM articles WHERE a_id = ?', a_id)
  halt 404, 'Article not found' unless @row

  @links = db.execute(
    "SELECT a_id_2 AS 'a_id', al_id FROM article_links WHERE a_id_1 = ? " \
    "UNION SELECT a_id_1 AS 'a_id', al_id FROM article_links WHERE a_id_2 = ?",
    [a_id, a_id]
  )
  @all_articles = db.execute('SELECT * FROM articles WHERE a_id != ? ORDER BY a_id DESC', a_id)
  @navigator    = db_navigator(db, a_id: a_id)
  db.close
  erb :edit
end

post '/edit' do
  require_login

  a_id = params[:a_id].to_i
  halt 400, '?!' if a_id < 1

  update_title  = params[:update_title]
  update_status = params[:update_status] ? params[:update_status].to_i : nil
  update_body   = params[:update_body]
  add_link      = params[:add_link]  && !params[:add_link].empty?  ? params[:add_link].to_i  : nil
  delete_link   = params[:delete_link] && !params[:delete_link].empty? ? params[:delete_link].to_i : nil

  mutating = update_title || !update_status.nil? || update_body || add_link || delete_link
  verify_csrf! if mutating

  db      = open_db
  datestr = Time.now.strftime('%Y-%m-%d %H:%M')

  if update_title
    title = CGI.escapeHTML(update_title).strip
    db.execute('UPDATE articles SET a_title = ?, a_mod_date = ? WHERE a_id = ?',
               [title, datestr, a_id])
  end

  unless update_status.nil?
    db.execute('UPDATE articles SET a_status = ? WHERE a_id = ?', [update_status, a_id])
  end

  if update_body
    body = CGI.escapeHTML(update_body)
    db.execute('UPDATE articles SET a_body = ?, a_mod_date = ? WHERE a_id = ?',
               [body, datestr, a_id])
    db_delete_keywords(db, a_id)
    db_add_keywords(db, a_id, body)
    db.close
    redirect "/?a_id=#{a_id}"
    return
  end

  db_add_link(db, a_id, add_link)     if add_link
  db_delete_link(db, delete_link)     if delete_link

  # Re-render edit page after title/status/link changes
  @csrf_token   = csrf_token
  @a_id         = a_id
  @row          = db.get_first_row('SELECT * FROM articles WHERE a_id = ?', a_id)
  @links        = db.execute(
    "SELECT a_id_2 AS 'a_id', al_id FROM article_links WHERE a_id_1 = ? " \
    "UNION SELECT a_id_1 AS 'a_id', al_id FROM article_links WHERE a_id_2 = ?",
    [a_id, a_id]
  )
  @all_articles = db.execute('SELECT * FROM articles WHERE a_id != ? ORDER BY a_id DESC', a_id)
  @navigator    = db_navigator(db, a_id: a_id)
  db.close
  erb :edit
end

# ═══════════════════════════════════════════════════════════════════════════════
# FILE UPLOAD
# ═══════════════════════════════════════════════════════════════════════════════

ALLOWED_EXTS = {
  'jpeg' => %w[image/jpeg],
  'jpg'  => %w[image/jpeg],
  'png'  => %w[image/png],
  'svg'  => %w[image/svg+xml application/xml text/xml text/html],
  'docx' => %w[application/vnd.openxmlformats-officedocument.wordprocessingml.document application/zip],
  'xls'  => %w[application/vnd.ms-excel application/zip application/octet-stream],
  'xlsm' => %w[application/vnd.ms-excel.sheet.macroenabled.12 application/zip],
  'tbz'  => %w[application/x-bzip2 application/gzip application/x-gzip application/octet-stream],
  'tgz'  => %w[application/gzip application/x-gzip application/x-bzip2 application/octet-stream],
}.freeze

MAX_UPLOAD_SIZE = 10 * 1024 * 1024  # 10 MB

get '/upload' do
  require_login
  @csrf_token = csrf_token
  @error      = nil
  @success    = nil
  erb :upload
end

post '/upload' do
  require_login
  verify_csrf!

  @csrf_token = csrf_token
  @error      = nil
  @success    = nil

  upload = params[:image]

  if upload.nil? || upload[:filename].to_s.empty?
    @error = 'No file selected.'
    return erb :upload
  end

  # Sanitise filename: keep only alphanumerics, dash, underscore, dot
  raw_name  = File.basename(upload[:filename].to_s)
  safe_name = raw_name.gsub(/[^a-zA-Z0-9._-]/, '_').lstrip.sub(/\A\.+/, '')

  ext = File.extname(safe_name).delete_prefix('.').downcase

  if !ALLOWED_EXTS.key?(ext)
    @error = "Extension not allowed. Permitted types: #{ALLOWED_EXTS.keys.join(', ')}"
    return erb :upload
  end

  tmp_path  = upload[:tempfile].path
  file_size = File.size(tmp_path)

  if file_size > MAX_UPLOAD_SIZE
    @error = 'File too large. Maximum size is 10 MB.'
    return erb :upload
  end

  real_mime = detect_mime(tmp_path)

  unless ALLOWED_EXTS[ext].include?(real_mime)
    @error = 'File content does not match the declared extension.'
    return erb :upload
  end

  dest = File.join(File.dirname(__FILE__), 'images', safe_name)
  begin
    FileUtils.cp(tmp_path, dest)
    @success = "File uploaded successfully as: #{h(safe_name)}"
  rescue => e
    @error = 'Failed to save uploaded file.'
  end

  erb :upload
end
