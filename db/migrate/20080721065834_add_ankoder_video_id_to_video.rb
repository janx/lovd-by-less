class AddAnkoderVideoIdToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :video_id, :integer
  end

  def self.down
    remove_column :videos, :video_id
  end
end
