class CreateUpdatedDeleteds < ActiveRecord::Migration
  def change
    create_table :updated_deleteds do |t|
      t.integer :record_id
      t.string :record_class
      t.string :type

      t.timestamps
    end
  end
end
