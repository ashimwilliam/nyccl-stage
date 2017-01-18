class BlogUser < ActiveRecord::Base
  attr_accessible :email

  validates_uniqueness_of :email
  validates_presence_of :email 

  def self.export_csv
      users = BlogUser.all

      csv_string = CSV.generate do |csv|
        csv << ["id", "email", "created date"]
        users.each do |user|
          csv << [user.id, user.email, user.created_at]
        end
      end

      csv_string
  end

end
