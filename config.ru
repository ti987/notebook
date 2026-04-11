# config.ru — Rack entry point
# Run with: rackup config.ru -p 4567
# Or behind Apache: ProxyPass / http://localhost:4567/
require_relative 'app'
run Sinatra::Application
