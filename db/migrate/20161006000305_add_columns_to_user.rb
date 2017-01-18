class AddColumnsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :user_type, :string
  	add_column :users, :source, :string
  end
end
