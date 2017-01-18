class RegistrationsController < Devise::RegistrationsController
  include Rack::Recaptcha::Helpers

  before_filter :check_user, only: [:success]

  layout false, only: [:success]

  def new
    if session[:guest_user_id]
      guest_user = GuestUser.find(session[:guest_user_id])
      guest_params = guest_user.attributes.slice('email', 'zipcode')
      @user = User.new(guest_params)
    else
      @user = User.new
    end

    @contest_copy = false
    if params[:ref]
      @contest_copy = true
      cookies.signed[:advisorref] = { value: params[:ref], expires: 24.hours.from_now }
    end
  end

  def create
    if request.path_parameters[:format] == 'json'
      begin
      user = User.new(:username => params['username'], :email => params['email'],
        :zipcode => params['zipcode'], :password => params['password'],
        :password_confirmation => params['password_confirmation'], :accepts_tos => params['accepts_tos'].to_i)
      if user.save

        device = DeviceDetail.where(:user_id => user.id, :device_id => params[:device_id])
        if device.blank?          
          device = DeviceDetail.find_by_device_token(params[:device_token])
          if device.present?
            device.update_attributes(:user_id => user.id, :device_token => params[:device_token])
          else
            DeviceDetail.create(:device_id => params[:device_id], :device_type => params[:device_type],
            :device_token => params[:device_token], :user_id => user.id) 
          end
        else
          if device.last.device_token !=  params[:device_token]
            device.last.update_attributes(:device_token => params[:device_token], :device_id => params[:device_id])
          end
        end

        if !user.avatar.blank?          
          user.custom_avatar_uid = CONFIG['img_host']+user.avatar.thumb('50x50#').url
        end
        
        render json: { message: "Success", status: true, data: user }, status: 200
        return
      else
        render json: {message: "Failed", status: false, errors: user.errors}, status: 401
      end

      rescue => error
        logger.warn "Internal server error: #{error}"
        render json: { message: "Sorry data invalid", status: false }, status: 500
      end

    else
      vgr_status = verify_google_recptcha(ENV['RECAPTCHA_SECRET_KEY'],params["g-recaptcha-response"])
      #respond_to do |format|
      if vgr_status
        params[:user].merge!(:user_type => "registered user", :source => "website")
        super
      else
        build_resource
        clean_up_passwords(resource)
        flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
        render :new
      end

      # if recaptcha_valid?
      #   params[:user].merge!(:user_type => "registered user", :source => "website")
      #   super
      # else
      #   build_resource
      #   clean_up_passwords(resource)
      #   flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
      #   flash.delete :recaptcha_error
      #   render :new
      # end
    end
  end

  def verify_google_recptcha(secret_key,response)
    status = `curl "https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{response}"`
    logger.info "---------------Google reCaptcha Status ==> #{status}"
    hash = JSON.parse(status)
    hash["success"] == true ? true : false
  end

  def success
    # Referral check/create
    if cookies[:advisorref]
      ref_code = ReferralCode.find_by_code(cookies.signed[:advisorref])

      if ref_code
        contest = ref_code.contest
        user = User.find(ref_code.user_id)
      end
      
      unless !contest || Referral.find_by_referred_id(current_user.id) || DateTime.now.to_date > contest.end_date
        Referral.create({ referrer_id: ref_code.user_id, contest_id: ref_code.contest_id, referred_id: current_user.id })
        user.send_raffle?(contest)
      end
    end

    step = params[:step].blank? ? 0 : params[:step].to_i
    if step.is_a?(Integer) && [1, 2].include?(step)
      @form = "step#{step}"
    else
      raise ActiveRecord::RecordNotFound
    end

    if request.put?

      if current_user.update_attributes(params[:user])

        if step == 1
          return redirect_to registration_success_path(2)
        else
          return redirect_to profile_root_path
        end
      else
        raise "Error saving user"
      end
    end

    @page = Page.find_by_absolute_url!("/registrations/success",
        select: "id, title, meta_description, teaser, copy")

  end

  private
    def check_user
      redirect_to "/" if current_user.blank?
    end

  protected

  def after_sign_up_path_for(resource)
    registration_success_path(1)
  end

  def after_inactive_sign_up_path_for(resource)
    registration_success_path(1)
  end
end
