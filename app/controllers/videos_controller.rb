class VideosController < ApplicationController
  skip_filter :check_permissions, :login_required
  prepend_before_filter :get_profile
  before_filter :setup
  
  def index
    @upload_url = "http://api.ankoder.com/files/upload"

    respond_to do |want|
      want.html
      want.rss {render :layout => false}
    end
  end

  def show
    @video = Video.find params[:id]
    if params[:format] == 'flv'
      response.headers['Content-Type'] = 'video/x-flv; charset=utf-8'
      redirect_to get_download_url(@video.flv_id)
    else
      render :layout => false
    end
  end

  def create
    message = ActiveSupport::JSON.decode params[:message]
    result = message['result']

    if result == 'success'
      @video = @profile.videos.build :name => message['video_name'], :video_id => message['video_id']
      if @video.save
        # 20 = $ankoder.profiles.find_by_name 'Flash HD'
        $ankoder.jobs.create :original_file_id => @video.video_id, :profile_id => 20, :postback_url => "#{PROTOCOL_HOST_PORT}#{converted_profile_video_path(@profile, @video)}"
        flash[:notice] = 'Video successfully uploaded'
      end
    end

    logger.debug @video.errors.inspect
    render :text => nil, :layout => false
  end

  def converted
    message = ActiveSupport::JSON.decode params[:message]
    @video.update_attribute(:flv_id, message['convert_video_id'].to_i) if message['result'] == 'success'
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

  def get_download_url(vid)
    api_url = Ankoder::Video.url_for vid
    cmd = "curl -si '#{api_url}'"
    location = nil
    IO.popen(cmd) do |f| location = f.readlines.find {|l| l =~ /Location/}[10..-1].strip end
    location
  end
end
