# dkv
[![Coverage Status](https://coveralls.io/repos/github/darrendao/dkv/badge.svg?branch=master)](https://coveralls.io/github/darrendao/dkv?branch=master)

This repo is a coding exercise for implementing a distributed key value service.

## Requirements
* Ruby 2.2.3 or greater. Refer to rbenv or RVM for managing your Ruby installations on your development environment.
* bundler gem installed (needed for dependency management)
```
sudo gem install bundler
```
* Install native dev packages for ruby, sqlite, libxslt and libxml2. For example, on Centos, you can run
```
sudo yum install ruby-devel
sudo yum groupinstall 'Development Tools'
sudo yum install sqlite-devel
sudo yum install libxml2-devel libxslt-devel
```
* On Ubuntu, you can run
```
sudo apt-get install build-essential
sudo apt-get install ruby-dev
sudo apt-get install libsqlite3-dev
sudo apt-get install libxslt-dev libxml2-dev
```
* Install all Ruby gems dependency
```
bundle install
```
## Development
* To start the app in development mode
```
ruby app.rb
```

## Running tests
* Tests are written as specs and stored under the spec directory.
* Tests can be run as followed
```
RACK_ENV=test rake test
```
* This repo has been integrated with Travis CI. When changes are made to the repo, Travis CI will automatically run the tests.
