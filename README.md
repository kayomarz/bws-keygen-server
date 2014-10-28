## Requirements

 + Ruby 1.9.3

## How to run the server

    ruby server.js

## Commands

For convenience, following are the curl commands to access the API

    curl -X POST -d "" localhost:4567/key
    curl -X POST -d "" localhost:4567/key/get
    curl -X PUT -d "" localhost:4567/key/123abc/unblock
    curl -X PUT -d "" localhost:4567/key/123abc/keepalive
    curl -X DELETE localhost:4567/key/123abc

## Changes

### Tue Oct 28 17:54:32 IST 2014

 - Added rspec tests
 - bugfixes
