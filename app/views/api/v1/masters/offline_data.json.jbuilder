if @timestamp
  json.status true
  json.message "Success"
  json.data do
  json.terms_of_use @terms_of_use

  json.scholarships @scholarships.each do |scholarship_record|
    if scholarship_record.updated_at >= @timestamp
      json.scholarship scholarship_record
    end
  end

  json.events @events.each do |event_record|
  	event_record = Event.find(event_record.id)
    if event_record.updated_at >= @timestamp
      json.event event_record
    end
  end  

  json.apply @page_apply.children.active.skinny.ordered.each do |kid|
  if (kid.faqs.active.present? || kid.resources.present?)
  kid = Page.find(kid.id)
  if kid.updated_at >= @timestamp
  json.apply_id kid.id
  json.main_title kid.short_title.strip
  json.text kid.teaser
  end
  json.faq_questions kid.faqs.active.each do |faq|
  	if faq.updated_at >= @timestamp
  	json.question_id faq.id
  	json.question faq.question
    str = ActionView::Base.full_sanitizer.sanitize(faq.answer.html_safe)
    str = str.gsub("&nbsp;", "")
    str = str.gsub("&ldquo;", "")
    str = str.gsub("&rdquo;", "")
    str = str.gsub("&rsquo;", "")
    str = str.squish    	
    json.answer str
    end    
  end

  json.recommended_resources kid.resources.each do |resource|
  	if resource.updated_at >= @timestamp
  	json.resource_id resource.id
  	json.name resource.name.squish
  	str = ActionView::Base.full_sanitizer.sanitize(resource.body.html_safe)
    str = str.gsub("&nbsp;", "")
    str = str.gsub("&ldquo;", "")
    str = str.gsub("&rdquo;", "")
    str = str.gsub("&rsquo;", "")
    str = str.squish  	
  	json.body str
    end
  end
  end
  end

  json.faqs main_nav.each do |p|
  p = Page.find(p.id)
  if p.updated_at >= @timestamp
  json.main_nav_id p.id
  json.main_nav_title p.title
  end
  json.type child_nav(p).each do |c|  	
  	if c.faqs.present?
  	c = Page.find(c.id)
  	if c.updated_at >= @timestamp
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
  end
  
  json.deleted_record @deleted.each do |entry|
    json.record_id entry.record_id
    json.record_class entry.record_class	
  end

  end
else
json.status true
json.message "Success"
json.data do
json.about_contact_us do
  json.about_text @about_us
  json.social_media @social_media
  json.address @address
  json.contact_mail @contact_mail
end
json.terms_of_use @terms_of_use

json.apply @page_apply.children.active.skinny.ordered.each do |kid|
  if (kid.faqs.active.present? || kid.resources.present?)
  json.apply_id kid.id
  json.main_title kid.short_title.strip
  json.text kid.teaser
  json.faq_questions kid.faqs.active.each do |faq|
  	json.question_id faq.id
  	json.question faq.question
    str = ActionView::Base.full_sanitizer.sanitize(faq.answer.html_safe)
    str = str.gsub("&nbsp;", "")
    str = str.gsub("&ldquo;", "")
    str = str.gsub("&rdquo;", "")
    str = str.gsub("&rsquo;", "")
    str = str.squish    	
    json.answer str    
  end

  json.recommended_resources kid.resources.each do |resource|
  	json.resource_id resource.id
  	json.name resource.name.squish
  	str = ActionView::Base.full_sanitizer.sanitize(resource.body.html_safe)
    str = str.gsub("&nbsp;", "")
    str = str.gsub("&ldquo;", "")
    str = str.gsub("&rdquo;", "")
    str = str.gsub("&rsquo;", "")
    str = str.squish  	
  	json.body str
  end
  end
end  	  	

json.faqs main_nav.each do |p|
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

json.scholarships @scholarships
json.events @events

end
end

