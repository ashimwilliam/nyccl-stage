class BookmarkFaq < ActiveRecord::Base
  attr_accessible :faq_id, :user_id
  belongs_to :user
  belongs_to :faq
end
