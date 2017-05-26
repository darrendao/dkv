require 'rubygems'
require 'data_mapper'

class User
  include DataMapper::Resource
  property :id, Serial
  property :token, Text, key: true

  def namespace(key)
    "#{id}/#{key}"
  end
end
