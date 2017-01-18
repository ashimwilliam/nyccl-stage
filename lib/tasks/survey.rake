require 'securerandom'
namespace :survey do
  desc 'Send  Survey Template to User for the present day'
  task survey_template: :environment do
  	@survey_templates = SurveyTemplate.where(:send_date => Date.today)

  	if @survey_templates.present?
  		@survey_templates.each do |template|

  			target_user = template.user_type
           
  			#if target_user == "registered"
            emails = template.identifier.split('/')
    
            emails.each do |email|
  				    user = User.find_by_email(email)
               
              if user.present?
  					    user_survey_template = UserSurveyTemplate.new
  					    user_survey_template.user_id = user.id
  					    user_survey_template.survey_template_id = template.id
  					    user_survey_template.email_secure_token = SecureRandom.hex()
  					    user_survey_template.save
  				      TemplateMailer.delay(queue: 'questions').template_mail(user_survey_template)                
              else

                guest_user = GuestUser.find_by_email(email)
                if guest_user.present?
                  guest_user_survey_template = GuestUserSurveyTemplate.new
                  guest_user_survey_template.guest_user_id = guest_user.id
                  guest_user_survey_template.survey_template_id = template.id
                  guest_user_survey_template.email_secure_token = SecureRandom.hex()
                  guest_user_survey_template.save
                  TemplateMailer.delay(queue: 'questions').guest_user_template_mail(guest_user_survey_template)  
                else  
                  guest_user = GuestUser.create!(email: email, zipcode: 111111)
                  guest_user_survey_template = GuestUserSurveyTemplate.new
                  guest_user_survey_template.guest_user_id = guest_user.id
                  guest_user_survey_template.survey_template_id = template.id
                  guest_user_survey_template.email_secure_token = SecureRandom.hex()
                  guest_user_survey_template.save
                  TemplateMailer.delay(queue: 'questions').guest_user_template_mail(guest_user_survey_template) 
                end 
              end 
  				  end
  			# elsif target_user == "unregistered"

  			# 	GuestUser.all.each do |user|
  			# 		guest_user_survey_template = GuestUserSurveyTemplate.new
  			# 		guest_user_survey_template.guest_user_id = user.id
  			# 		guest_user_survey_template.survey_template_id = template.id
  			# 		guest_user_survey_template.email_secure_token = SecureRandom.hex()
  			# 		guest_user_survey_template.save
  			# 		#TemplateMailer.guest_user_template_mail(guest_user_survey_template).deliver
  			# 	end

  			# elsif target_user == "both"

  			# 	User.all.each do |user|
  			# 		user_survey_template = UserSurveyTemplate.new
  			# 		user_survey_template.user_id = user.id
  			# 		user_survey_template.survey_template_id = template.id
  			# 		user_survey_template.email_secure_token = SecureRandom.hex()
  			# 		user_survey_template.save
  			# 		#TemplateMailer.template_mail(user_survey_template).deliver
  			# 	end		
           
     #      GuestUser.all.each do |user|
  			# 		guest_user_survey_template = GuestUserSurveyTemplate.new
  			# 		guest_user_survey_template.guest_user_id = user.id
  			# 		guest_user_survey_template.survey_template_id = template.id
  			# 		guest_user_survey_template.email_secure_token = SecureRandom.hex()
  			# 		guest_user_survey_template.save
  			# 		#TemplateMailer.guest_user_template_mail(guest_user_survey_template).deliver
  			# 	end		  

  			#end	

  		end	

    end		
    
  end

end
