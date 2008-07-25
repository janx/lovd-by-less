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
    redirect_to profile_videos_path(@profile)
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

  private

  def get_profile
    @profile = Profile[params[:profile_id] || params[:id]]
  end
  
  def setup
    @user = @profile.user
    @videos = @profile.videos.paginate(:all, :page => @page, :per_page => @per_page)
    @video = Video.new
  end

end
