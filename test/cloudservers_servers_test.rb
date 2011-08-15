$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'tempfile'

class CloudServersServersTest < Test::Unit::TestCase

  include TestConnection

  def setup
    @conn=get_test_connection
  end
  
  def test_list_servers

    response = mock()
    response.stubs(:code => "200", :body => fixture('list_servers.json'))

    @conn.stubs(:csreq).returns(response)
    servers=@conn.list_servers

    assert_equal 2, servers.size
    assert_equal 1234, servers[0][:id]
    assert_equal "sample-server", servers[0][:name]

  end

  def test_get_server

    server=get_test_server
    assert_equal "sample-server", server.name
    assert_equal 2, server.imageId
    assert_equal 1, server.flavorId
    assert_equal "e4d909c290d0fb1ca068ffaddf22cbd0", server.hostId
    assert_equal "BUILD", server.status
    assert_equal 60, server.progress
    assert_equal "67.23.10.132", server.addresses[:public][0]
    assert_equal "67.23.10.131", server.addresses[:public][1]
    assert_equal "10.176.42.16", server.addresses[:private][0]

    assert_equal "67.23.10.132", server.addresses[0].address
    assert_equal "67.23.10.131", server.addresses[1].address
    assert_equal "10.176.42.16", server.addresses[2].address

    assert_equal "67.23.10.132", server.accessipv4
  end

  def test_get_server11

    server=get_test_server11
    assert_equal "sample-server", server.name
    assert_equal "52415800-8b69-11e0-9b19-734f6f006e54", server.imageId
    assert_equal "52415800-8b69-11e0-9b19-734f216543fd", server.flavorId
    assert_equal "e4d909c290d0fb1ca068ffaddf22cbd0", server.hostId
    assert_equal "BUILD", server.status
    assert_equal 60, server.progress
    assert_equal "67.23.10.132", server.addresses[0].address
    assert_equal "public", server.addresses[0].label
    assert_equal 4, server.addresses[0].version
    assert_equal "::babe:67.23.10.132", server.addresses[1].address
    assert_equal "public", server.addresses[1].label
    assert_equal 6, server.addresses[1].version
    assert_equal "67.23.10.131", server.addresses[2].address
    assert_equal "public", server.addresses[2].label
    assert_equal 4, server.addresses[2].version
    assert_equal "::babe:4317:0A83", server.addresses[3].address
    assert_equal "public", server.addresses[3].label
    assert_equal 6, server.addresses[3].version
    assert_equal "10.176.42.16", server.addresses[4].address
    assert_equal "private", server.addresses[4].label
    assert_equal 4, server.addresses[4].version
    assert_equal "::babe:10.176.42.16", server.addresses[5].address
    assert_equal "private", server.addresses[5].label
    assert_equal 6, server.addresses[5].version

    assert_equal "67.23.10.132", server.accessipv4
    assert_equal "::babe:67.23.10.132", server.accessipv6

  end


  def test_share_ip

    server=get_test_server
    response = mock()
    response.stubs(:code => "200")

    @conn.stubs(:csreq).returns(response)

    assert server.share_ip(:sharedIpGroupId => 100, :ipAddress => "67.23.10.132")
  end

  def test_share_ip_requires_shared_ip_group_id

    server=get_test_server

    assert_raises(CloudServers::Exception::MissingArgument) do
      assert server.share_ip(:ipAddress => "67.23.10.132")
    end

  end

  def test_share_ip_requires_ip_address

    server=get_test_server

    assert_raises(CloudServers::Exception::MissingArgument) do
      assert server.share_ip(:sharedIpGroupId => 100)
    end

  end

  def test_unshare_ip

    server=get_test_server
    response = mock()
    response.stubs(:code => "200")

    @conn.stubs(:csreq).returns(response)

    assert server.unshare_ip(:ipAddress => "67.23.10.132")

  end

  def test_unshare_ip_requires_ip_address

    server=get_test_server

    assert_raises(CloudServers::Exception::MissingArgument) do
      assert server.share_ip({})
    end

  end

  def test_create_server_requires_name

    assert_raises(CloudServers::Exception::MissingArgument) do
        @conn.create_server(:imageId => 2, :flavorId => 2)
    end

  end

  def test_create_server_requires_image_id

    assert_raises(CloudServers::Exception::MissingArgument) do
        @conn.create_server(:name => "test1", :flavorId => 2)
    end

  end

  def test_create_server_requires_flavor_id

    assert_raises(CloudServers::Exception::MissingArgument) do
        @conn.create_server(:name => "test1", :imageId => 2)
    end

  end

  def test_create_server_with_local_file_personality

    response = mock()
    response.stubs(:code => "200", :body => fixture('create_server.json'))
    @conn.stubs(:csreq).returns(response)

    tmp = Tempfile.open('ruby_cloud_servers')
    tmp.write("hello")
    tmp.flush

    server = @conn.create_server(:name => "sample-server", :imageId => 2, :flavorId => 2, :metadata => {'Racker' => 'Fanatical'}, :personality => {tmp.path => '/root/tmp.jpg'})

    assert_equal "blah", server.adminPass

  end

  def test_create_server_with_personalities

    response = mock()
    response.stubs(:code => "200", :body => fixture('create_server.json'))
    @conn.stubs(:csreq).returns(response)

    server = @conn.create_server(:name => "sample-server", :imageId => 2, :flavorId => 2, :metadata => {'Racker' => 'Fanatical'}, :personality => [{:path => '/root/hello.txt', :contents => "Hello there!"}, {:path => '/root/.ssh/authorized_keys', :contents => ""}])

    assert_equal "blah", server.adminPass

  end

  def test_too_many_personalities

    personalities=[
        {:path => "/tmp/test1.txt", :contents => ""},
        {:path => "/tmp/test2.txt", :contents => ""},
        {:path => "/tmp/test3.txt", :contents => ""},
        {:path => "/tmp/test4.txt", :contents => ""},
        {:path => "/tmp/test5.txt", :contents => ""},
        {:path => "/tmp/test6.txt", :contents => ""}
    ]

    assert_raises(CloudServers::Exception::TooManyPersonalityItems) do
        @conn.create_server(:name => "sample-server", :imageId => 2, :flavorId => 2, :metadata => {'Racker' => 'Fanatical'}, :personality => personalities)
    end

  end

private
  def get_test_server

    response = mock()
    response.stubs(:code => "200", :body => fixture('test_server.json'))

    @conn=get_test_connection

    @conn.stubs(:csreq).returns(response)
    return @conn.server(1234) 

  end

  def get_test_server11

    response = mock()
    response.stubs(:code => "200", :body => fixture('test_server11.json'))

    @conn=get_test_connection11

    @conn.stubs(:csreq).returns(response)
    return @conn.server("52415800-8b69-11e0-9b19-734f000004d2")
  end

end
