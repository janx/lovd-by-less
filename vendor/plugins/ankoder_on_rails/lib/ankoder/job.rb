module Ankoder
  class JobFailed < RuntimeError; end
  
  class Job < Base
    # Encode the given video into the given format
    #
    #   Video_ID is the video id that get from Ankoder::Download
    #   Profile_ID is selected from the list of Ankoder::Profile.find(:all)
    # 
    #   Job.create(:original_file_id => "Video_ID", :profile_id => "Profile_ID", 
    #              :postback_url => 'http://your_own_host.com/postback/job')
    def self.create(attributes={})
      job = super
      return job 
    end
  end
end
