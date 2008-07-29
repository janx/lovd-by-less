class Video < ActiveRecord::Base
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'

  belongs_to :profile

  validates_presence_of :profile_id, :video_id


  file_column :location
    
  def after_create
    feed_item = FeedItem.create(:item => self)
    ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end

  def after_find
    @flv = Ankoder::Video.find flv_id
  rescue
    @flv = Ankoder::Video.new :thumb => ''
  end

  def thumbnail
    @flv.thumb
  end

end
