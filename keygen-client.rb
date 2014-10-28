# Ignore the following line to add a path to $:, it is only to fix a local
# ruby platform issue
$:.unshift(File.join("./httpclient/", "lib"))

require "httpclient"
# require "json"
# require "url"

class KeygenClient

  URL_PREFIX = "http://localhost:4567"

  def initialize
    @client = HTTPClient.new
  end

  # def get(path)
  #   response = @client.get(_url(path))
  #   "" << response.status_code << "\n" << response.body
  # end

  def post(path)
    response = @client.post(_url(path), "")
    [response.status_code, response.body]
  end

  def put(path)
    response = @client.put(_url(path), "") 
    [response.status_code, response.body]
 end

  def delete(path)
    response = @client.delete(_url(path)) 
    [response.status_code, response.body]
  end

  private

  def _url(path="/")
    "" << URL_PREFIX << path
  end

end

if __FILE__ == $0

client = KeygenClient.new
client.post("/key")

end
