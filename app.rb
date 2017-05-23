# myapp.rb
require 'sinatra'
require 'sinatra/namespace'
require 'redic/cluster'
require 'data_mapper'
require './lib/user.rb'

configure do
  set :kv_store, {}
  set :redis_store, Redic::Cluster.new("redis://localhost:6379")

  env = ENV['RACK_ENV'] || "development"
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/#{env}.db")
  DataMapper.finalize
  DataMapper.auto_upgrade!
end

def authenticate!
  @user = User.find(token: @request_payload[:token])
  halt 403 unless @user
end

get '/' do
  'Hello world!'
end

namespace '/api/v1' do
  before do
    halt 403 unless request.env['HTTP_AUTHENTICATION']
    @u = User.first(token: request.env['HTTP_AUTHENTICATION'])
    halt 403 unless @u
  end

  head '/kv/:key' do
    key = params[:key]
    ret = settings.redis_store.call('EXISTS', key)
    if ret == 0
      status 404
      "NOT FOUND"
    else
      "OK"
    end
  end

  get '/kv/:key' do
    key = params[:key]
    val = settings.redis_store.call("GET", key)
    if val
      val
    else
      status 404
      "NOT FOUND"
    end
  end

  put '/kv/:key' do
    key = params[:key]
    val = request.body.read
    settings.redis_store.call("SET", key, val)
  end

  delete '/kv/:key' do
    key = params[:key]
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
    user.to_json
  else
    status 400
    "Unable to create user"
  end
end
