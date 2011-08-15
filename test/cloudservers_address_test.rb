$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'tempfile'

class CloudServersServersTest < Test::Unit::TestCase

  include TestConnection

  def setup
    @conn=get_test_connection
  end

  def test_address

    addresses = Array.new

    response = mock()
    response.stubs(:code => "200", :body => fixture('test_server.json'))

    @conn=get_test_connection

    @conn.stubs(:csreq).returns(response)

    data = JSON.parse(response.body)["server"]

    address_info = data["addresses"]
    address_info.each do |label, addr|
      addr.each { |a| addresses << CloudServers::Address.new(label,a)}
    end

    assert_equal "67.23.10.132", addresses[0].address
    assert_equal "public", addresses[0].label
    assert_equal 4, addresses[0].version
    assert_equal "67.23.10.131", addresses[1].address
    assert_equal "public", addresses[1].label
    assert_equal "10.176.42.16", addresses[2].address
    assert_equal "private", addresses[2].label

  end

  def test_address_11

    addresses = Array.new

    response = mock()
    response.stubs(:code => "200", :body => fixture('test_server11.json'))

    @conn=get_test_connection

    @conn.stubs(:csreq).returns(response)

    data = JSON.parse(response.body)["server"]

    address_info = data["addresses"]
    address_info.each do |label, addr|
      addr.each { |a| addresses << CloudServers::Address.new(label,a)}
    end

    assert_equal "67.23.10.132", addresses[0].address
    assert_equal "public", addresses[0].label
    assert_equal 4, addresses[0].version
    assert_equal "::babe:67.23.10.132", addresses[1].address
    assert_equal "public", addresses[1].label
    assert_equal 6, addresses[1].version
    assert_equal "67.23.10.131", addresses[2].address
    assert_equal "public", addresses[2].label
    assert_equal 4, addresses[2].version
    assert_equal "::babe:4317:0A83", addresses[3].address
    assert_equal "public", addresses[3].label
    assert_equal 6, addresses[3].version
    assert_equal "10.176.42.16", addresses[4].address
    assert_equal "private", addresses[4].label
    assert_equal 4, addresses[4].version
    assert_equal "::babe:10.176.42.16", addresses[5].address
    assert_equal "private", addresses[5].label
    assert_equal 6, addresses[5].version

  end

  def address_list_test

  end


end

