# Key Server:

# Notes:
#
# A separate concurrent thread can be used to maintain data constraints:
# i.e. unblocked keys are automatically released within 60 seconds and
# keys which are not keept alive for more than 5 minutes should be deleted.
#
# There are various options for "a separate thread" including use of a Ruby
# Thread, an event loop or an external process.
#
# An external database could be used which would have its own locking mechanism.
# An event loop would have been convenient to expire and unblocking
# keys. However, since this problem might require minimum use of external
# libraries, Ruby Thread is used.
# 
# Ruby 1.9.3 is used which supports Threads. The GIL (Global Interpreter Lock)
# acts in our favour to simplify data sharing issues.
#
# Assumptions:
# 
# Following are assumed, since they are not stated in the problem:
# - The solution does not ensure data persistancy. i.e. if the server is
#   restarted, generated keys and their state will be lost.
# - This server can run only in one instance.  Multiple instances cannot be
#   run to increase the cpacity to handle more requests.  This is because
#   data is stored local to a server instance.
# - Since this server relies on GIL, this server will not work with JRuby

# E1. generate keys.
# POST /key
#
# E2. get an available key, block it, If no eligible key available serve 404.
# POST /key/get
#
# E3. unblock a key. Unblocked keys can be served via E2 again.
# PUT /key/<key>/unblock
#
# E4. delete a key
# DELETE /key/<key>' do
#
# E5. keepalive. Delete if unused five minutes.
# PUT /key/<key>/keepalive
#
# R1. All blocked keys should get released automatically within 60 secs if E3 is
# not called. 
#
# No endpoint call should result in an iteration of whole set of keys i.e. no
# endpoint request should be O(n). They should either be O(lg n) or O(1). 

RUBY_VERSION_REQUIRED = "1.9.3"

require 'rubygems'
require 'sinatra'

require_relative 'lib/key-list'

def rubyVersionCheck
  # puts "RUBY_PLATFORM #{RUBY_PLATFORM}"
  # puts "RUBY_DESCRIPTION #{RUBY_DESCRIPTION}"
  # puts "RUBY_VERSION #{RUBY_VERSION}"
  RUBY_VERSION.match(RUBY_VERSION_REQUIRED) ? true : false
end

if (!rubyVersionCheck)
  puts "This program requires to be run on version: " << RUBY_VERSION_REQUIRED
  exit(1)
end

keyUtil = KeyList.new

# For convenience during dev, populate initial data to get started.
# keyUtil.generate
# keyUtil.generate
# keyUtil.generate

# E1. Generate
post '/key' do
  key = keyUtil.generate
  key ? [200, ""] : [500, ""]
end

# E2. Get available key or 404
post '/key/get' do
  key = keyUtil.get
  key ? [200, key] : [404, "No key unavailble"]
end

# E3. Unblock
put '/key/:key/unblock' do
  keyUtil.unblock(params[:key])
  [200, ""]
end

# E4. Delete
delete '/key/:key' do
  key = keyUtil.delete(params[:key])
  key ? [200, key] : [404, "No such resource"]
end

# E5. Keep alive a key
put '/key/:key/keepalive' do
  key = keyUtil.keepalive(params[:key])
  key ? [200, ""] : [404, "No such resource"]
end


# E5. Keep alive a key
put '/debugreset' do
  sizeStr = keyUtil.debug_reset
  [200, sizeStr]
end

# Only for debugging: Dump data
get '/debug' do
  [200, keyUtil.debug]
end
