class CreateUserBoroughs < ActiveRecord::Migration
  def change

    add_column :users, :borough_id, :integer
    add_index :users, :borough_id

    add_column :boroughs, :show_in_filters, :boolean, default: true
    add_column :boroughs, :show_in_settings, :boolean, default: true

  end
end
