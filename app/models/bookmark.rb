# == Schema Information
#
# Table name: bookmarks
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  folder_id   :integer         not null
#  resource_id :integer         not null
#  order       :integer         default(0)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Bookmark < ActiveRecord::Base

  belongs_to :user
  belongs_to :folder
  belongs_to :blog_post
  belongs_to :event
  belongs_to :resource, counter_cache:true

  attr_accessible :user, :folder, :resource, :resource_id, :user_id, :folder_id, :blog_post_id, :event_id, :blog_post, :event

  delegate :name, :teaser, to: :resource, prefix: true

  validates :user, :folder, presence: true

  after_create :fix_counter_cache
  after_save :fix_counter_cache
  after_destroy :fix_counter_cache


  private
    def fix_counter_cache
      if self.folder_id_was
        Folder.find(self.folder_id_was).update_bookmarks_count
      end
      self.folder.update_bookmarks_count
    end

  class << self
    def ordered
      order("bookmarks.created_at DESC")
    end
  end
end
