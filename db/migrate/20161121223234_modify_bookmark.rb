class ModifyBookmark < ActiveRecord::Migration
  def up
  	change_column :bookmarks, :resource_id, :integer, :null => true
  end

  def down
  	change_column :bookmarks, :resource_id, :integer, :null => false
  end
end
