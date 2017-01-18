class CreateBookmarkEvents < ActiveRecord::Migration
  def change
    create_table :bookmark_events do |t|
      t.integer :user_id
      t.integer :event_id

      t.timestamps
    end
  end
end
