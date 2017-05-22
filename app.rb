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
  key = params[:key]
  val = request.body.read
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

head '/redis/:key' do
  key = params[:key]
  ret = settings.redis_store.call('EXISTS', key)
  if ret == 0
    status 404
    "NOT FOUND"
  else
    "OK"
  end
end
