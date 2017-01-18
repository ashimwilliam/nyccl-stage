class AddFieldToBookmarks < ActiveRecord::Migration
  def change
  	add_column :bookmarks, :blog_post_id, :integer
  	add_column :bookmarks, :event_id, :integer
  end
end
