require 'hmac'
require 'hmac-sha1'

module Ankoder
  # Get a video from Ankoder
  #
  # Videos.find(video_id)
  #
  class Video < Base
    def self.url_for(video_id, expires_in = nil)
      message = {:access_key => Configuration::access_key, :expires => expires(expires_in)}.to_json
      encoded_message = Base64.encode64(HMAC::SHA1::digest(Configuration::private_key, message)).strip
      "http://#{Configuration::host}/video/#{video_id}/download/?message=#{CGI.escape(message)}&signature=#{encoded_message}"
    end
    private
    
    # Will return one of three values, in the following order of precedence:
    #
    #   1) The current time in seconds since the epoch plus the number of seconds passed in
    #      the +:expires_in+ option
    #   2) The current time in seconds since the epoch plus the default number of seconds (60 seconds)
    def self.expires(expires_in =nil)
      Time.now.to_i + (expires_in || DEFAULT_EXPIRY)
    end
  end
end
