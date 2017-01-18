class UpdatedDeleted < ActiveRecord::Base
  #t.integer :record_id
  #t.string :record_class

  attr_accessible :record_class, :record_id, :type
end
