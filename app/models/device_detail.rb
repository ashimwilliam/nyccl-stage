# == Schema Information
#
# Table name: device_details
#
# t.string   "device_type"
# t.string   "device_id"
# t.string   "device_token"
# t.string   "access_id"
# t.integer  "user_id"
# t.datetime "created_at",   :null => false
# t.datetime "updated_at",   :null => false
 

class DeviceDetail < ActiveRecord::Base
 
  belongs_to :user

  attr_accessible :device_type, :device_id, :device_token, :user_id, :access_id
  
end
