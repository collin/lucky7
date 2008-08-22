require 'vendor/sinatra/lib/sinatra/test/spec'
require 'lib/server'
# abandoned for general retardedness :(
describe "Server" do
  it "" do
    get_it '/'
    should.be.ok
  end
end