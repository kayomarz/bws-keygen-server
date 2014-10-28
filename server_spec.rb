require_relative "keygen-client"

keygen_client = KeygenClient.new

RSpec.describe "keygen server api calls" do

  before(:each) do
    # puts "before"
    status, body = keygen_client.put("/debugreset")
    expect(status).to eq(200)
    # puts "debugreset: #{body}"
  end

  it "generate, block a key" do
    status, body = keygen_client.post("/key/get")
    expect(status).to eq(404)

    status, body = keygen_client.post("/key")
    expect(status).to eq(200)

    status, key = keygen_client.post("/key/get")
    expect(status).to eq(200)
  end

  it "generate, block, unblock, block a key" do
    status, body = keygen_client.post("/key")
    expect(status).to eq(200)

    status, key = keygen_client.post("/key/get")
    expect(status).to eq(200)

    status, body = keygen_client.put("/key/#{key}/unblock")
    expect(status).to eq(200)

    # puts "Get same key"
    status, sameKey = keygen_client.post("/key/get")
    expect(sameKey).to eq(key)
    expect(status).to eq(200)
  end

  it "generate, block, unblock, delete a key" do
    status, body = keygen_client.post("/key")
    expect(status).to eq(200)

    status, key = keygen_client.post("/key/get")
    expect(status).to eq(200)

    status, body = keygen_client.put("/key/#{key}/unblock")
    expect(status).to eq(200)

    status, body = keygen_client.delete("/key/#{key}")
    expect(status).to eq(200)

    status, body = keygen_client.post("/key/get")
    expect(status).to eq(404)
  end


  # it "generate, block, unblock, delete" do

  #   status, body = keygen_client.post("/key/get")
  #   puts "BODY: #{body}"
  #   expect(status).to eq(404)

  #   status, body = keygen_client.post("/key")
  #   expect(status).to eq(200)

  #   status, key = keygen_client.post("/key/get")
  #   puts "BODY: #{key}"
  #   expect(status).to eq(200)

  #   status, body = keygen_client.post("/key/get")
  #   puts "BODY: #{body}"
  #   expect(status).to eq(404)

  #   status, body = keygen_client.put("/key/#{key}/unblock")
  #   puts "BODY: #{key}"
  #   expect(status).to eq(200)

  #   puts "Get same key"
  #   status, sameKey = keygen_client.post("/key/get")
  #   puts "BODY: #{sameKey}"
  #   expect(sameKey).to eq(key)
  #   expect(status).to eq(200)

  #   status, body = keygen_client.put("/key/#{key}/unblock")
  #   puts "BODY: #{key}"
  #   expect(status).to eq(200)

  #   status, body = keygen_client.delete("/key/#{key}")
  #   puts "BODY: #{body}"
  #   expect(status).to eq(200)
  # end

end
