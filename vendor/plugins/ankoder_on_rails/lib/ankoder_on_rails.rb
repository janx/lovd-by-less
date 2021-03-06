require "xmlsimple"
require "cgi"

module Ankoder
	
	OUT_FORMAT = "xml" unless const_defined? :OUT_FORMAT
  RESOURCES = %w{job profile download video account upload} unless const_defined? :RESOURCES
  DEFAULT_EXPIRY = 300 unless const_defined? :DEFAULT_EXPIRY
  
  # These are error codes you receive if you use ping options
  ERROR_CODE = {
                100 => "Unknown error",
                101 => "Unsupported audio codec",
                102 => "Unsupported video codec",
                103 => "This video cannot be encoded in this format",
                104 => "Wrong settings for audio",
                105 => "Wrong settings for video",
                106 => "Cannot retrieve info from this video",
                107 => "Not a video file",
                108 => "Video too long",
                109 => "The container of this video is not supported yet",
                110 => "The audio can't be resampled",
                201 => "404 Not Found",
                202 => "Bad address",
                300 => "No more credit available"
              } unless const_defined? :ERROR_CODE
              
  class NotAuthorized < RuntimeError; end
  class RequestError < RuntimeError; end
  class ResourceNotFound < RuntimeError; end
  class ServerError < RuntimeError; end
  class SessionNotFound < RuntimeError; end
  
  class Configuration
    cattr_accessor :private_key , :access_key , :auth_user , :auth_password , :host , :port
  end
  
  def self.load_config
    begin
      globe_config = YAML::load(ERB.new((IO.read("#{RAILS_ROOT}/config/ankoder.yml"))).result)
      auth_config = globe_config["#{RAILS_ENV}"]
      Configuration::private_key   = auth_config["private_key"] 
      Configuration::access_key    = auth_config["access_key"] 
      Configuration::auth_user     = auth_config["auth_user"]
      Configuration::auth_password = auth_config["auth_password"]
      Configuration::host          = auth_config["host"] || "api.ankoder.com"
      Configuration::port          = auth_config["port"] || "80"
    rescue
      raise $!, " Ankoder: problems trying to load '\"#{RAILS_ROOT}/config/ankoder.yml\")}'"
      raise
    end
  end
  
  # Convert the XML response into Hash
  def self.response(xml)
    XmlSimple.xml_in(xml, {'ForceArray' => false})
  end
  
  # sanitize url
  def self.sanitize_url(url)
    return url.gsub(/[^a-zA-Z0-9:\/\.\-\+_\?\=&]/) {|s| CGI::escape(s)}.gsub("+", "%20")
  end
  
  def self.url_exist?(url , limit = 10)
    raise false if limit == 0
    response = Net::HTTP.get_response(URI.parse(url))
    case response
    when Net::HTTPSuccess     then true
    when Net::HTTPRedirection then url_exist?(response['location'], limit - 1)
    else
      false
    end
  rescue 
    false
  end
end

$: << File.dirname(File.expand_path(__FILE__))

Ankoder.load_config if defined?(RAILS_ROOT)
require "ankoder/ext"
require "ankoder/version"
require "ankoder/browser"
require "ankoder/auth"
require "ankoder/base"
require "ankoder/video"
require "ankoder/account"
require "ankoder/download"
require "ankoder/job"
require "ankoder/profile"

class Hash
  include Ankoder::CoreExtension::HashExtension
end

class Array
  include Ankoder::CoreExtension::ArrayExtension
end
