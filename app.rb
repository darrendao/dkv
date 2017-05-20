# myapp.rb
require 'sinatra'
require "redic/cluster"

configure do
  set :kv_store, {}
  set :redis_store, Redic::Cluster.new("redis://localhost:6379")
end

get '/' do
  'Hello world!'
end

get '/kv/:key' do
  key = params[:key]
  if settings.kv_store[key]
    puts settings.kv_store[key]
    settings.kv_store[key].to_s
  else
    status 404
  end
end

put '/kv/:key' do
  key = params[:key]
  settings.kv_store[key] = Time.now  
end

delete '/kv/:key' do
  key = params[:key]
  settings.kv_store[key] = nil
end

get '/redis/:key' do
  key = params[:key]
  val = settings.redis_store.call("GET", key)
  if val
    val
  else
    status 404
    "NOT FOUND"
  end
end

put '/redis/:key' do
  val = request.body.read
  key = params[:key]
  settings.redis_store.call("SET", key, val)
end

delete '/redis/:key' do
  key = params[:key]
  ret = settings.redis_store.call("DEL", key)
  if ret == 0
    status 404
    "NOT FOUND"
  else
    "OK"
  end
end
