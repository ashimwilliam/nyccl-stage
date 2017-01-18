json.status true
json.message "Success"
json.data @page.children.active.skinny.ordered.each do |kid|
  if (kid.faqs.active.present? || kid.resources.present?)
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