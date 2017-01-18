class SessionsController < Devise::SessionsController

  before_filter :check_user, only: [:success]

  # POST /resource/sign_in
  def create
    if request.path_parameters[:format] == 'json'
      begin

      guest_user = GuestUser.find_by_email(params[:email])
      if guest_user        
        render json: {message: "Failed guest user", status: false}, status: 401
      end

      if params[:email]
        resource = User.find_for_database_authentication(:email => params[:email])
      else
        resource = User.find_for_database_authentication(:username => params[:username])
      end      
      return invalid_login_attempt unless resource
            
      if resource.valid_password?(params[:password])
        resource.ensure_authentication_token!  #make sure the user has a token generated

        device = DeviceDetail.where(:user_id => resource.id, :device_id => params[:device_id])
        if device.blank?          
          device = DeviceDetail.find_by_device_token(params[:device_token])
          if device.present?
            device.update_attributes(:user_id => resource.id, :device_token => params[:device_token])
          else
            DeviceDetail.create(:device_id => params[:device_id], :device_type => params[:device_type],
            :device_token => params[:device_token], :user_id => resource.id) 
          end
        else
          if device.last.device_token !=  params[:device_token]
            device.last.update_attributes(:device_token => params[:device_token], :device_id => params[:device_id])
          end
        end
        if !resource.avatar.blank?          
          resource.custom_avatar_uid = CONFIG['img_host']+resource.avatar.thumb('50x50#').url
        end

        bookmark_events = resource.bookmark_events
        bookmark_faqs = resource.bookmark_faqs

        render :json => { message: "Success", status: true, :authentication_token => resource.authentication_token, :data => resource, bookmark_events: bookmark_events, bookmark_faqs: bookmark_faqs }, :status => 200
        return
      else
        render json: { message: "Invalid email/username or password", status: false }, status: 401
        return
      end

      rescue => error
        logger.warn "Internal server error: #{error}"
        render json: { message: "Sorry data invalid", status: false }, status: 500
      end

    else
    guest_user = GuestUser.find_by_email(resource_params[:login])

    if guest_user
      flash.now[:alert] = 'Oops, your account hasnt been activated yet. Please <a href="/users/register/signup">Sign Up</a> first!'
      return render :new
    end

    user = User.find_by_email(resource_params[:login])
    if user    
     if(user.failed_attempts != 0 && user.failed_attempts % 3 == 0)      
      random_token = SecureRandom.urlsafe_base64(nil, false)
      user.reset_password_token   = random_token
      user.reset_password_sent_at = Time.now.utc
      user.save(validate: false)
      @alert_msg = ''
      @alert_msg = 'alert'
      QuestionMailer.delay(queue: 'questions').automated_password_recovery(user)    
      return render :new
     end
    end

    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    #sign_in(resource_name, resource)

    respond_to do |format|
      format.html {
        respond_with resource, :location => after_sign_in_path_for(resource)
      }
      format.js {
        render
      }
    end
    end
  end

  def destroy
    if request.path_parameters[:format] == 'json'
      begin
      # expire auth token
      resource = User.where(:authentication_token => params[:auth_token]).first
      if resource
        #resource.reset_authentication_token!
        device = DeviceDetail.where(:user_id => resource.id, :device_id => params[:device_id])
        if device.present?
          device.last.destroy
        end
        render json: { message: "Success", status: true }, status: 200
      else
        render json: { message: "Invalid auth token", status: false }, status: 401
      end

      rescue => error
        logger.warn "Internal server error: #{error}"
        render json: { message: "Sorry data invalid", status: false }, status: 500
      end

    else      
      render json: { message: "Server is unable to fullfil this request", status: false }, status: 500
    end
  end

  def new
    if session[:guest_email]
      @guest_email = User.find_by_email(session[:guest_email]).blank? ? '' : session[:guest_email]
    end

    unless request.referrer.blank? || request.xhr?
      
      url = request.referrer

      # 
      # This fixes sifter #14631 but if it needs to happen again
      # consider fixing globally.
      # 
      # The problem is that the referrer value does not change when
      # bounced through the 401 unauthorized.
      url = (URI(url).path == '/profile/ask-an-adviser') ? '/profile/ask-an-adviser/new' : url

      logger.error "\n\n +++#{url}\n\n"
      unless URI(url).path.starts_with?("/login")
        # Let's just keep devise out of this, okay?
        session[:user_return_to] = url
      end
    end

    super
  end

  def invalid_login_attempt
    warden.custom_failure!    
    render json: {message: "Invalid email/username or password", status: false}, status: 401
  end

end
