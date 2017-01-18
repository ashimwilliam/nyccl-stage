class AddFieldsToUserSettings < ActiveRecord::Migration
  def change
  	add_column :user_settings, :notify_new_scholarship, :boolean
    add_column :user_settings, :notify_new_event, :boolean
    add_column :user_settings, :notify_scholarship_winner, :boolean 
    add_column :user_settings, :notify_end_scholarship, :boolean
    add_column :user_settings, :notify_scholarship_end_vote, :boolean
  end
end
