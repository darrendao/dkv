require File.expand_path '../spec_helper.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

# Start from scratch
redis = Redic::Cluster.new("redis://localhost:6379")  
redis.call("FLUSHALL")
User.all.destroy
auth_token = SecureRandom.urlsafe_base64(64)
user = User.create(token: auth_token)

describe 'health check' do
  it 'should return pong if I ping it' do
    get '/ping'
    last_response.status.must_equal 200
    last_response.body.must_include 'pong'
  end
end

describe 'GET operation' do
  before do
    header 'Authentication', auth_token
    put '/api/v1/kv/key1', 'value1'
    put '/api/v1/kv/key2', 'value2'
  end

  it 'should return correct HTTP status if key is not found' do
    get '/api/v1/kv/nonexistingkey1'
    last_response.status.must_equal 404
  end

  it 'should return correct value if key is found' do
    get '/api/v1/kv/key1'
    last_response.status.must_equal 200
    last_response.body.must_equal 'value1'
    get '/api/v1/kv/key2'
    last_response.status.must_equal 200
    last_response.body.must_equal 'value2'
  end
end

describe 'SET operation' do
  before do
    header 'Authentication', auth_token
    put '/api/v1/kv/key1', 'value1'
  end
  it 'should overwrite existing key value' do
    get '/api/v1/kv/key1'
    last_response.status.must_equal 200
    last_response.body.must_equal 'value1'
    put '/api/v1/kv/key1', 'new value'
    get '/api/v1/kv/key1'
    last_response.status.must_equal 200
    last_response.body.must_equal 'new value'
  end  
end

describe 'DELETE operation' do
  before do
    header 'Authentication', auth_token
    put '/api/v1/kv/key1', 'value1'
  end
  it 'should delete the key and value from the data store' do
    delete '/api/v1/kv/key1'
    last_response.status.must_equal 200
    get '/api/v1/kv/key1'
    last_response.status.must_equal 404
  end
  it 'should return correct HTTP status if key is not there' do
    delete '/api/v1/kv/nonexistingkey1'
    last_response.status.must_equal 404
  end
end

describe 'HEAD operation' do
  before do
    header 'Authentication', auth_token
    put '/api/v1/kv/key1', 'value1'
  end
  it 'should find the existing key' do
    head '/api/v1/kv/key1'
    last_response.status.must_equal 200
    last_response.body.must_be_empty
  end
  it 'should not find an non-existing key' do
    head '/api/v1/kv/nonexistingkey1'
    last_response.status.must_equal 404
    last_response.body.must_be_empty
  end
end

describe 'Authenticated requests' do
  it 'should return 403 for all operations' do
    head '/api/v1/kv/key'
    last_response.status.must_equal 403
    get '/api/v1/kv/key'
    last_response.status.must_equal 403
    delete '/api/v1/kv/key'
    last_response.status.must_equal 403
    put '/api/v1/kv/key', 'value1'
    last_response.status.must_equal 403
  end
end

describe 'User creation' do
  it 'should return json with auth token' do
    post '/users'
    last_response.status.must_equal 201
    user = JSON.parse(last_response.body)
    user['token'].wont_be_nil
  end
end
