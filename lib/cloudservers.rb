#!/usr/bin/env ruby
# 
# == Cloud Servers API
# ==== Connects Ruby Applications to Rackspace's {Cloud Servers service}[http://www.rackspacecloud.com/cloud_hosting_products/servers]
# By H. Wade Minter <minter@lunenburg.org>, Mike Mayo <mike.mayo@rackspace.com>, and Dan Prince <dan.prince@rackspace.com>
#
# See COPYING for license information.
# Copyright (c) 2009, Rackspace US, Inc.
# ----
# 
# === Documentation & Examples
# To begin reviewing the available methods and examples, peruse the README.rodc file, or begin by looking at documentation for the 
# CloudServers::Connection class.
#
# The CloudServers class is the base class.  Not much of note aside from housekeeping happens here.
# To create a new CloudServers connection, use the CloudServers::Connection.new(:username => USERNAME, :api_key => API_KEY)

module CloudServers

  AUTH_USA = "https://auth.api.rackspacecloud.com"
  AUTH_UK = "https://lon.auth.api.rackspacecloud.com"
  AUTH_ALPHA = "http://alpha.ord.servers.api.rackspacecloud.com:8774"

  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'rubygems'
  require 'json'
  require 'date'

  unless "".respond_to? :each_char
    require "jcode"
    $KCODE = 'u'
  end

  $:.unshift(File.dirname(__FILE__))
  require 'cloudservers/version'
  require 'cloudservers/authentication'
  require 'cloudservers/connection'
  require 'cloudservers/server'
  require 'cloudservers/image'
  require 'cloudservers/flavor'
  require 'cloudservers/shared_ip_group'
  require 'cloudservers/exception'
  
  # Constants that set limits on server creation
  MAX_PERSONALITY_ITEMS = 5
  MAX_PERSONALITY_FILE_SIZE = 10240
  MAX_SERVER_PATH_LENGTH = 255
  MAX_PERSONALITY_METADATA_ITEMS = 5
  
  # Helper method to recursively symbolize hash keys.
  def self.symbolize_keys(obj)
    case obj
    when Array
      obj.inject([]){|res, val|
        res << case val
        when Hash, Array
          symbolize_keys(val)
        else
          val
        end
        res
      }
    when Hash
      obj.inject({}){|res, (key, val)|
        nkey = case key
        when String
          key.to_sym
        else
          key
        end
        nval = case val
        when Hash, Array
          symbolize_keys(val)
        else
          val
        end
        res[nkey] = nval
        res
      }
    else
      obj
    end
  end
  
  def self.paginate(options = {})
    path_args = []
    path_args.push(URI.encode("limit=#{options[:limit]}")) if options[:limit]
    path_args.push(URI.encode("offset=#{options[:offset]}")) if options[:offset]
    path_args.join("&")
  end
  

end
