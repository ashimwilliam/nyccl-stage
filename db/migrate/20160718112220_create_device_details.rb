class CreateDeviceDetails < ActiveRecord::Migration
  def change
  	create_table :device_details do |t|
      t.string :device_type
      t.string :device_id
      t.string :device_token
      t.integer :user_id
      t.string :access_id

      t.timestamps    
    end
  end
end