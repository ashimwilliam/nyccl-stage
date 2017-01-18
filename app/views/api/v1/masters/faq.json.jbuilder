json.status true
json.message "Success"
json.data main_nav.each do |p|
  json.main_nav_id p.id
  json.main_nav_title p.title
  json.type child_nav(p).each do |c|
  	if c.faqs.present?
  	json.child_nav_id c.id
    json.child_nav_title c.title
    json.questions c.faqs.active.each do |i|
    	json.id i.id
    	json.question i.question    	
    	str = ActionView::Base.full_sanitizer.sanitize(i.answer.html_safe)
    	str = str.gsub("&nbsp;", "")
    	str = str.gsub("&ldquo;", "")
    	str = str.gsub("&rdquo;", "")
    	str = str.gsub("&rsquo;", "")
    	str = str.squish    	
    	json.answer str
    end
    end
  end  	  
end


