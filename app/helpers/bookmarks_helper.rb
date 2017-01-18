module BookmarksHelper

  def bookmarked?(resource_id)
    !current_user.blank? && current_user.has_bookmark?(resource_id)
  end


  def blog_bookmarked?(blog_post_id)
  	!current_user.blank? && current_user.has_blog_bookmark?(blog_post_id)
  end	

  def event_bookmarked?(event_id)
  	!current_user.blank? && current_user.has_event_bookmark?(event_id)
  end

  def bookmark_title(bookmarked)
    return "Login or sign up" if current_user.blank?
    bookmarked ? "Edit" : "Save to folder"
  end

end
