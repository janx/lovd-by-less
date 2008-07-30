class VideosController < ApplicationController
  skip_filter :check_permissions, :login_required
  prepend_before_filter :get_profile
  before_filter :setup
  
  def index
    @upload_url = "http://api.ankoder.com/files/upload"
    @policy = <<END
{
  "expiration": "2009-01-01T12:00:00.000Z",
  "conditions": [
    {"bucket": "ankoder_upload" },
    {"acl": "public-read" },
    ["starts-with", "$key", "uploads/"],
    ["starts-with", "$Filename", ""],
  ]
}
END
    @policy_base64 = [@policy].pack("m").gsub("\n","")
    @signature = [HMAC::SHA1::digest('wQz2otdTCd84VPJMPFRW04L+3h9Qqgje9wRpw6Gn', @policy_base64)].pack("m").gsub("\n","")

    respond_to do |want|
      want.html
      want.rss {render :layout => false}
    end
  end

  def show
    @video = Video.find params[:id]
    render :layout => false
  end

  def create
    message = ActiveSupport::JSON.decode params[:message]
    result = message['result']

    if result == 'success'
      @video = @profile.videos.build :name => message['video_name'], :video_id => message['video_id']
      if @video.save
        # flv_profile = $ankoder.profile.find_by_name 'Flash320x240'
        # flv_profile.id # => 3
        $ankoder.jobs.create :original_file_id => @video.video_id, :profile_id => 3, :postback_url => url_for(:action => :flv, :id => @video.id, :host => HOST_PORT)
      end
    end

    logger.debug @video.errors.inspect
    render :text => nil, :layout => false
  end

  def flv
    @video = Video.find params[:id]
    message = ActiveSupport::JSON.decode params[:message]
    result = message['result']
    if result == 'success'
      @video.flv_id =  message['convert_video_id']
      @video.save
    else
      logger.debug message
    end
    render :text => nil, :layout => false
  end

  def destroy
    @video = Video.find params[:id]
    @video.destroy
    render :text => nil, :layout => false
  end

  private

  def get_profile
    @profile = Profile[params[:profile_id] || params[:id]]
  end
  
  def setup
    @user = @profile.user
    @videos = @profile.videos.paginate(:all, :page => @page, :per_page => @per_page)
  end

end
