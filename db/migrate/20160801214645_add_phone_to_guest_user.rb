class AddPhoneToGuestUser < ActiveRecord::Migration
  def change
  	add_column  :guest_users, :phone, :string
  end
end
