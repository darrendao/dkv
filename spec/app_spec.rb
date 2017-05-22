require File.expand_path '../spec_helper.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

redis = Redic::Cluster.new("redis://localhost:6379")  
redis.call("FLUSHALL")

describe 'my example app' do
  it 'should successfully return a greeting' do
    get '/'
    last_response.body.must_include 'Hello world!'
  end
end

describe 'GET operation' do
  before do
    put '/redis/key1', 'value1'
    put '/redis/key2', 'value2'
  end

  it 'should return correct HTTP status if key is not found' do
    get '/redis/nonexistingkey1'
    last_response.status.must_equal 404
  end

  it 'should return correct value if key is found' do
    get '/redis/key1'
    last_response.status.must_equal 200
    last_response.body.must_equal 'value1'
    get '/redis/key2'
    last_response.status.must_equal 200
    last_response.body.must_equal 'value2'
  end
end

describe 'SET operation' do
  before do
    put '/redis/key1', 'value1'
  end
  it 'should overwrite existing key value' do
    get '/redis/key1'
    last_response.status.must_equal 200
    last_response.body.must_equal 'value1'
    put '/redis/key1', 'new value'
    get '/redis/key1'
    last_response.status.must_equal 200
    last_response.body.must_equal 'new value'
  end  
end

describe 'DELETE operation' do
  before do
    put '/redis/key1', 'value1'
  end
  it 'should delete the key and value from the data store' do
    delete '/redis/key1'
    last_response.status.must_equal 200
    get '/redis/key1'
    last_response.status.must_equal 404
  end
  it 'should return correct HTTP status if key is not there' do
    delete '/redis/nonexistingkey1'
    last_response.status.must_equal 404
  end
end

describe 'HEAD operation' do
  before do
    put '/redis/key1', 'value1'
  end
  it 'should find the existing key' do
    head '/redis/key1'
    last_response.status.must_equal 200
  end
  it 'should not find an non-existing key' do
    head '/redis/nonexistingkey1'
    last_response.status.must_equal 404
  end
end
