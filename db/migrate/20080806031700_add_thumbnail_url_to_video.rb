class AddThumbnailUrlToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :thumbnail_url, :string
  end

  def self.down
    remove_column :videos, :thumbnail_url
  end
end
