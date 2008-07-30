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
        flash[:notice] = 'Video successfully uploaded'
      end
    end

    logger.debug @video.errors.inspect
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

  def get_download_url(vid)
    api_url = Ankoder::Video.url_for vid
    cmd = "curl -si '#{api_url}'"
    location = nil
    IO.popen(cmd) do |f| location = f.readlines.find {|l| l =~ /Location/}[10..-1].strip end
    location
  end
end
