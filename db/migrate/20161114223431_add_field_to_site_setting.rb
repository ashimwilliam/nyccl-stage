class AddFieldToSiteSetting < ActiveRecord::Migration
  def change
  	add_column :site_settings, :pop_up, :boolean
  end
end
