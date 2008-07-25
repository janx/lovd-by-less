module Ankoder
  class DownloadFailed < RuntimeError; end

  class Download < Base   
    # Download file from the given URL
    #  Download.create('url' => 'http://host.com/file.avi', :postback_url => 'http://your_own_host.com/postback/download')
    # 
    #  the return result would be the Video record that you can save for further checking
    # 
    #  if the postback url is included, the download result will send back to your server in JSON format
    def self.create(attributes={})
      download = super
      return download 
    end
  end
end
