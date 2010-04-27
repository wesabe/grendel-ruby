$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

begin
  require 'bundler'
rescue LoadError
  require 'rubygems'
  require 'bundler'
end
Bundler.setup

require 'grendel'
require 'spec'
require 'spec/autorun'
require 'webmock/rspec'

include WebMock

Spec::Runner.configure do |config|
  WebMock.disable_net_connect!

  # helper to add Content-Type: application/json to each request
  def stub_json_request(method, uri, body, headers = {})
    headers = headers.update("Content-Type" => "application/json")
    status = headers.delete(:status) || "200 OK"
    stub_request(method, uri).
      to_return(:body => body, :status => status, :headers => headers)
  end
end
