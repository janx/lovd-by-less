class Video < ActiveRecord::Base
  named_scope :latest, lambda {|*args|
    limit = args[0]||12
    {:order => 'created_at desc', :limit => limit}
  }

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'

  belongs_to :profile

  validates_presence_of :profile_id, :video_id


  file_column :location
    
  def after_create
    feed_item = FeedItem.create(:item => self)
    ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end

  # use delegate insteand of after_create
  # because thumbnail may not be ok on ankoder only few
  # seconds after you created video
  def thumbnail
    if thumbnail_url.blank?
      begin
        @ankoder_video ||= Ankoder::Video.find(video_id)
      rescue
        @ankoder_video = Ankoder::Video.new :thumb => ''
      end
      self.thumbnail_url = @ankoder_video.thumb
      save
    end
    thumbnail_url
  end

end
