# myapp.rb
require 'sinatra'
require 'sinatra/namespace'
require 'redic/cluster'
require 'data_mapper'
require './lib/user.rb'

configure do
  env = ENV['RACK_ENV'] || "development"
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/#{env}.db")
  DataMapper.finalize
  DataMapper.auto_upgrade!

  redis_host =  ENV['REDIS_HOST'] || 'localhost'
  set :redis_store, Redic::Cluster.new("redis://#{redis_host}:6379")

  register ::Sinatra::Namespace
  set :protection, true
  set :protect_from_csrf, true
  set :bind, '0.0.0.0'
end

get '/ping' do
  'pong'
end

namespace '/api/v1' do
  before do
    halt 403 unless request.env['HTTP_AUTHENTICATION']
    @user = User.first(token: request.env['HTTP_AUTHENTICATION'])
    halt 403 unless @user
  end

  head '/kv/:key' do
    key = @user.namespace(params[:key])
    ret = settings.redis_store.call('EXISTS', key)
    if ret == 0
      status 404
    else
      status 200
    end
  end

  get '/kv/:key' do
    key = @user.namespace(params[:key])
    val = settings.redis_store.call("GET", key)
    if val
      val
    else
      status 404
      "NOT FOUND"
    end
  end

  put '/kv/:key' do
    key = @user.namespace(params[:key])
    val = request.body.read
    settings.redis_store.call("SET", key, val)
  end

  delete '/kv/:key' do
    key = @user.namespace(params[:key])
    ret = settings.redis_store.call("DEL", key)
    if ret == 0
      status 404
      "NOT FOUND"
    else
      "OK"
    end
  end
end

post '/users' do
  token = SecureRandom.urlsafe_base64(64)
  user = User.create(token: token)
  if user.id
    status 201
    user.to_json
  else
    status 400
    "Unable to create user"
  end
end
