class AddFlvIdToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :flv_id, :integer
  end

  def self.down
    remove_column :videos, :flv_id
  end
end
