require 'net/http'
require 'uri'
class Api::V1::MastersController < ApplicationController  
  #before_filter :authenticate_user!, only: [:reply_to_question]
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { message: "Sorry record not found", status: false }, status: 200
  end

  def faq
    begin
    @page = Page.find_by_absolute_url!('/faq')
    respond_to do |format|
      format.json
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def offline_data
    begin    
    @page_faq = Page.find_by_absolute_url!('/faq')
    @terms_of_use = Page.find_by_absolute_url!("/terms-of-use").copy

    @about_us = "NYC College Line supports New Yorkers to prepare for, get in to and complete college by connecting them to expert advice,scholarships,local programs and events."
    @social_media = ['http://www.facebook.com/NYCCollegeLine', 'https://twitter.com/NYCCollegeLine', 'http://nyccollegeline.tumblr.com','http://nyccollegeline.org/feed?format=rss']
    @address = '16 Court Street, Brooklyn, NY, USA, 10005'
    @contact_mail = 'info@nyccollegeline.org'    

    @page_apply = Page.find_by_absolute_url!('/apply')

    @scholarships = Scholarship.active

    events = Event.active.skinny
    @events = events.future.ordered

    if params[:timestamp]
      require 'date'
      @timestamp = DateTime.strptime(params[:timestamp],'%s')      
      terms_of_use = Page.find_by_absolute_url!("/terms-of-use")
      if terms_of_use.updated_at >= @timestamp
        @terms_of_use = terms_of_use.copy
      else
        @terms_of_use = ''
      end
      @deleted = UpdatedDeleted.where("updated_at >= ?", @timestamp)      
    end

    respond_to do |format|
      format.json
    end    

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def apply_data
    begin
    @page = Page.find_by_absolute_url!('/apply')
    respond_to do |format|
      format.json
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def terms_policy
    begin
    #privacy_policy = Page.find_by_absolute_url!("/privacy-policy").copy
    terms_of_use = Page.find_by_absolute_url!("/terms-of-use").copy
    render json: { message: "Success", status: true, :terms_of_use => terms_of_use }, status: 200

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def events
    begin
    events = Event.active.skinny
    events = events.future.ordered

    events_list = Array.new
    events.each do |event|
      events_list << Event.find(event.id)
    end

    if !events.blank?
      render json: { message: "Success", status: true, :data => events_list }, status: 200
    else
      render json: { message: "No active events to display", status: true }, status: 200
    end
    
    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def event_show
    begin
    event = Event.find(params[:id])    
    event = Event.includes(:subway_lines).find_by_permalink!(params[:id]) if !event.present?

    if !event.blank?
      comments = event.comments
      render json: { message: "Success", status: true, :data => event, :comments => comments }, status: 200
    else
      render json: { message: "No such event to display", status: false }, status: 200
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def event_comment
    begin    
    commentable = Event.find(params[:event_id])    
    commentable = Event.find_by_permalink!(params[:event_id]) if !commentable.present?
    user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]

    if commentable && user
      comment = commentable.comments.build(:content => params[:comment], :user_id => user.id)      
    else
      render json: { message: "Failed", status: false }, status: 200
      return
    end

    if comment.save
      commentable.last_commented_at = Time.now
      commentable.last_commenter_id = user.id
      commentable.comments_count = commentable.comments.size+1      
      commentable.save
      render json: { message: "Success", status: true }, status: 200
      return
    else      
      render json: { message: "Failed", status: false }, status: 200
      return
    end
    
    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def scholarships
    begin
    scholarships = Scholarship.active
    if !scholarships.blank?
      render json: { message: "Success", status: true, :data => scholarships }, status: 200
    else
      render json: { message: "No active scholarships to display", status: true }, status: 200
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def scholarship_form
    begin

    scholarship = Scholarship.find(params[:scholarship_id])
    scholarship = Scholarship.find_by_permalink!(params[:scholarship_id]) if !scholarship.present?    
    #authenticate_user! if scholarship.require_authentication
    if scholarship
      scholarship_submission = ScholarshipSubmission.new(:agree_to_terms => params[:agree_to_terms], :birth_month => params[:birth_month], :birth_year => params[:birth_year], :order => 0,
        :email => params[:email], :first_name => params[:first_name], :high_school => params[:high_school], :last_name => params[:last_name], :video_url => params[:video_url], :title => params[:title],
        :of_age_or_consent => params[:of_age_or_consent], :phone => params[:phone], :scholarship_id => scholarship.id, :state => params[:state], :description => params[:description], :school_type_id => params[:school_type_id],
        :year_in_school => params[:year_in_school], :submission_format => params[:submission_format], :submission_prompt => params[:submission_prompt], :not_currently_enrolled => params[:not_currently_enrolled])
    else
      scholarship_submission = ScholarshipSubmission.new
      render json: { message: "Failed scholarship not found", status: false }, status: 200
      return
    end 

    if scholarship_submission.save      
      render json: { message: "Success", status: true, :data => scholarship.thank_you }, status: 200
      return
    else
      render json: { message: "Failed", status: false }, status: 200
      return
    end


    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
      return
    end
  end

  def about_us
    begin
    about_us = "NYC College Line supports New Yorkers to prepare for, get in to and complete college by connecting them to expert advice,scholarships,local programs and events."
    social_media = ['http://www.facebook.com/NYCCollegeLine', 'https://twitter.com/NYCCollegeLine', 'http://nyccollegeline.tumblr.com','http://nyccollegeline.org/feed?format=rss']
    address = '16 Court Street, Brooklyn, NY, USA, 10005'
    contact_mail = 'info@nyccollegeline.org'
    render json: { message: "Success", status: true, :about_text => about_us, :social_media => social_media, :address => address, :contact_mail => contact_mail }, status: 200

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  # def Facebook Login
  #app.apns_dev_cert = File.read("#{Rails.root}/vendor/pro_apns_certificate.pem")
  def facebook_login
    begin
    user = User.find_by_email(params[:email])    
    if user
      user.ensure_auth_token
      device = DeviceDetail.where(:user_id => user.id, :device_id => params[:device_id])
      if device.blank?          
        device = DeviceDetail.find_by_device_token(params[:device_token])
        if device.present?
          device.update_attributes(:user_id => user.id, :device_token => params[:device_token])
        else
          DeviceDetail.create(:device_id => params[:device_id], :device_type => params[:device_type],
           :device_token => params[:device_token], :user_id => user.id, :access_id => params[:fb_id]) 
        end
      else
        if device.last.device_token !=  params[:device_token]
          device.last.update_attributes(:device_token => params[:device_token], :device_id => params[:device_id])
        end
      end
      if !user.avatar.blank?          
        user.custom_avatar_uid = CONFIG['img_host']+user.avatar.thumb('50x50#').url
      end
      render json: { message: "Success", status: true, :authentication_token => user.authentication_token, data: user }, status: 200
      return
    else
      #guest_user = GuestUser.where(email: params[:email]).first
      username = params[:email][/[^@]+/]
      username = username+'_fb'
      password = username+'@facebook'

      new_user = User.new(:username => username, :email => params[:email], :zipcode => '10001',
        :password => password, :password_confirmation => password, :accepts_tos => 1)
      new_user.ensure_auth_token
      if new_user.save
        DeviceDetail.create(:device_id => params[:device_id], :device_type => params[:device_type],
          :device_token => params[:device_token], :user_id => new_user.id, :access_id => params[:fb_id]) 
        #QuestionMailer.delay(queue: 'questions').partial_user_welcome(new_user, password)
        render json: { message: "Success", status: true, :authentication_token => new_user.authentication_token, data: new_user }, status: 200
        return    
      else
        render json: { message: "Sorry data invalid", status: false }, status: 200
      end
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  # Ask-An-Advisor Guest User
  def ask_an_adviser_guest
    begin
    user = User.find_by_email(params[:guest_user_email])
    if user      
      guest_question = user.questions.new(:question => params[:guest_question] )      

      if guest_question.save
        QuestionMailer.delay(queue: 'questions').send_to_admins(guest_question)
        render json: { message: "Success", status: true }, status: 200        
      else
        guest_question = GuestQuestion.new(:question => params[:guest_question], :guest_user_id => user.id)
        render json: { message: "Success", status: true }, status: 200        
      end
      return
    end
    
    guest_user = GuestUser.find_by_email(params[:guest_user_email])

    if !guest_user
      guest_user = GuestUser.create(:email => params[:guest_user_email], :zipcode => params[:guest_user_zip])
    end

    guest_question = guest_user.guest_questions.new(:question => params[:guest_question])

    if guest_question.save
      QuestionMailer.delay(queue: 'questions').send_to_admins(guest_question)
      render json: { message: "Success", status: true }, status: 200
    else
      render json: { message: "Failed", status: false }, status: 200
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  # Ask-An-Advisor Regitered User
  def ask_an_adviser_user
    begin
    user = User.find(params[:user_id].to_i)
    if user      
      guest_question = user.questions.new(:question => params[:user_question] )      

      if guest_question.save
        QuestionMailer.delay(queue: 'questions').send_to_admins(guest_question)
        render json: { message: "Success", status: true }, status: 200        
      else
        guest_question = GuestQuestion.new(:question => params[:guest_question], :guest_user_id => user.id)
        render json: { message: "Success", status: true }, status: 200        
      end
      return
    else
      render json: { message: "Failed user not found", status: false }, status: 200
      return
    end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end    
  end 

  def reply_to_question
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      if user.present? 

        commentable = find_commentable
        @comment = commentable.comments.build(content: params[:content], commentable_id: commentable.id,
          commentable_type: commentable.class, user_id: user.id)
      
        @comment_size = commentable.comments.size

        unless @comment.save
          render js: "alert('All fields are required');"
        else
          commentable.last_commented_at = Time.now
          commentable.last_commenter = user
          commentable.on_commented if commentable.methods.include? :on_commented
          commentable.save
       
          url = URI("http://sms2.cdyne.com/sms.svc/AdvancedSMSSend")
               
          http = Net::HTTP.new(url.host, url.port)
           
          request = Net::HTTP::Post.new(url)
           
          request["content-type"] = 'application/json'
           
          request.body = '{
            "Concatenate": false,
            "IsUnicode": false,
            "LicenseKey":"b4b11a23-89a8-49b9-8e28-e5b0a0635d6e",
            "SMSRequests":[{
              "AssignedDID":"",
              "Message":"#{@comment.content}",
              "PhoneNumbers": "#{user.phone}",
              "ReferenceID":"123",
              "StatusPostBackURL":"http://smsalerts-usa.mobikasa.com/datawebhook/getsmsResult",
              "ScheduledDateTime":"\/Date(928164000000)\/"}]
            }'
           
          response = http.request(request)
          render json: { message: "Success", status: true, data: response.read_body  }, status: 200  
        end
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end 
  end 

  def get_question
    begin
      message = params[:message].partition('/')
      user_email = message.first
      user = User.find_by_email(user_email)
      if user
        user_question = user.questions.new(:question => message.last)
        if user_question.save
          QuestionMailer.delay(queue: 'questions').send_to_admins(user_question)
          user.update_attributes(:phone => params[:FromPhoneNumber])
          render json: { message: "Success", status: true }, status: 200        
        else
          render json: { message: "Failed", status: false }, status: 200 
        end
        return
      else
        guest_user =  GuestUser.find_by_email(user_email)
        
        if !guest_user
          guest_user = GuestUser.create(:email => user_email, :zipcode => '12312')
        end
         
        guest_question = guest_user.guest_questions.new(:question => message.last)

        if guest_question.save
          QuestionMailer.delay(queue: 'questions').send_to_admins(guest_question)
          guest_user.update_attributes(:phone => params[:FromPhoneNumber])
          render json: { message: "Success", status: true }, status: 200
        else
          render json: { message: "Failed", status: false }, status: 200
        end
      end
    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end

  end  

  def user_profile
    begin      
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
  
      if user.present?
        if !user.avatar.blank?          
          user.custom_avatar_uid = CONFIG['img_host']+user.avatar.thumb('50x50#').url
        end
        bookmark_events = user.bookmark_events
        bookmark_faqs = user.bookmark_faqs
        render json: { message: "Success", status: true, data: user, bookmark_events: bookmark_events, bookmark_faqs: bookmark_faqs }, status: 200
      else
        render json: { message: "User not found.", status: false }, status: 401
      end
      

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def user_scholarships
    begin
      user = User.find_by_authentication_token(params[:auth_token])  if params[:auth_token]

      if user.present?
        scholarships = ScholarshipSubmission.where(email: user.email)
        scholarships = 'No scholarship submission found.' if scholarships.blank?
        render json: { message: "Success", status: true, data: scholarships }, status: 200
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def edit_profile
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      if user.present?
        if request.get?
          bookmark_events = user.bookmark_events
          bookmark_faqs = user.bookmark_faqs
          render json: { message: "Success", status: true, data: user, bookmark_events: bookmark_events, bookmark_faqs: bookmark_faqs }, status: 200
        else
          if user.update_attributes(email: params[:email], username: params[:username], 
             zipcode: params[:zipcode]) 
            user.update_attributes(password: params[:password], password_confirmation: params[:password_confirmation]) unless params[:password].blank?
            if !user.avatar.blank?          
              user.custom_avatar_uid = CONFIG['img_host']+user.avatar.thumb('50x50#').url
            end
            bookmark_events = user.bookmark_events
            bookmark_faqs = user.bookmark_faqs
            render json: { message: "Success", status: true, data: user, bookmark_events: bookmark_events, bookmark_faqs: bookmark_faqs }, status: 200
          else
            render json: { message: "Failed to update.", status: false, errors: user.errors}, status: 401
          end        
        end  
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def delete_user_account    
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      
      if user.present?
        if !user.admin?
          user.destroy
          render json: { message: "Success", status: true }, status: 200
        else          
          render json: { message: "Admin user can't be deleted.", status: false }, status: 401
        end  
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def user_asked_questions
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      
      if user.present?
        adviser_questions = user.questions
        adviser_questions = 'No questions found.' if adviser_questions.blank?  
        render json: { message: "Success", status: true, data: adviser_questions }, status: 200
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def user_setting
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      if user.present?
        if request.get?
          render json: { message: "Success", status: true, data: user.user_settings }, status: 200
        else
          if user.user_settings.update_attributes(notify_new_scholarship: params[:notify_new_scholarship], notify_new_event: params[:notify_new_event],
            notify_scholarship_winner: params[:notify_scholarship_winner], notify_scholarship_end_vote: params[:notify_scholarship_end_vote], 
            notify_end_scholarship: params[:notify_end_scholarship])
            render json: { message: "Success", status: true }, status: 200        
          else
            render json: { message: "Failed to update.", status: false }, status: 200 
          end  
        end  
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end
  end

  def upload_photo
    begin
      user =  User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      if user.present?       
        if  user.update_attributes(:custom_avatar =>  params[:custom_avatar])
          if !user.avatar.blank?          
            user.custom_avatar_uid = CONFIG['img_host']+user.avatar.thumb('50x50#').url
          end          
          bookmark_events = user.bookmark_events
          bookmark_faqs = user.bookmark_faqs
          render json: { message: "Success", status: true, data: user, bookmark_events: bookmark_events, bookmark_faqs: bookmark_faqs }, status: 200        
        end
      else
        render json: { message: "User not found.", status: false }, status: 401
      end

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end  
  end    
  
  def bookmark_event
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      if user.present?
        if request.get?
          bookmark_events = user.bookmark_events
          render json: { message: "Success", status: true, data: bookmark_events }, status: 200
        elsif request.post?
          bookmark_event = user.bookmark_events.build(event_id: params[:event_id])
          if bookmark_event.save
            render json: { message: "Event Bookmarked", status: true }, status: 200
          else
            render json: { message: "False", status: false }, status: 200  
          end
        else
          bookmark_event = BookmarkEvent.find(params[:id])
          if bookmark_event.present?
            bookmark_event.destroy
            render json: { message: "Success", status: true }, status: 200
          else
            render json: { message: "No record found", status: true }, status: 401
          end   
        end  
      else
        render json: { message: "User not found.", status: false }, status: 401
      end  

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end     
  end

  def bookmark_faq
    begin
      user = User.find_by_authentication_token(params[:auth_token]) if params[:auth_token]
      if user.present?
        if request.get?
          bookmark_faqs = user.bookmark_faqs
           render json: { message: "Success", status: true, data: bookmark_faqs }, status: 200
        elsif request.post?
          bookmark_faq = user.bookmark_faqs.build(faq_id: params[:faq_id])
          if bookmark_faq.save
            render json: { message: "Faq Bookmarked", status: true }, status: 200
          else
            render json: { message: "False", status: false }, status: 401  
          end
        else
          bookmark_faq = BookmarkFaq.find(params[:id])
          if bookmark_faq.present?
            render json: { message: "Success", status: true }, status: 200
          else
            render json: { message: "No record found", status: true }, status: 401
          end  
        end  
      else
        render json: { message: "User not found.", status: false }, status: 401
      end  

    rescue => error
      logger.warn "Internal server error: #{error}"
      render json: { message: "Sorry data invalid", status: false }, status: 500
    end     
  end

  private
    def find_commentable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          cls = $1.classify.constantize
          if cls.column_names.include? 'permalink'
            return cls.find_by_permalink!(value)
          else
            return cls.find_by_id!(value)
          end
        end
      end
      nil
    end
end
