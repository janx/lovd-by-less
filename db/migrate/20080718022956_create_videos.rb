class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :name
      t.integer :profile_id
      t.text :description
      t.float :rate
      t.integer :watched
      t.boolean :public
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
