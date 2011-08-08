require 'test/unit'
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'cloudservers'
require 'rubygems'
require 'mocha'

module TestConnection

def get_test_connection 

    conn_response = {'x-server-management-url' => 'http://server-manage.example.com/path', 'x-auth-token' => 'dummy_token'}
    conn_response.stubs(:code).returns('204')
    server = mock(:use_ssl= => true, :verify_mode= => true, :start => true, :finish => true)
    server.stubs(:get).returns(conn_response)
    Net::HTTP.stubs(:new).returns(server)

    CloudServers::Connection.new(:username => "test_account", :api_key => "AABBCCDD11")

end

def get_test_connection11

    conn_response = {'x-server-management-url' => "http://server-manage.example.com/v1.1", 'x-auth-token' => 'dummy_token'}
    conn_response.stubs(:code).returns('204')
    server = mock( :start => true, :finish => true)
    server.stubs(:get).returns(conn_response)
    Net::HTTP.stubs(:new).returns(server)

    CloudServers::Connection.new(:username => "test_account", :api_key => "AABBCCDD11",:auth_url => CloudServers::AUTH_ALPHA)

end

end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.read(fixture_path + '/' + file)
end
