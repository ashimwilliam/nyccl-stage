class PasswordsController < Devise::PasswordsController
  layout "devise_layout"

  def create
    if request.path_parameters[:format] == 'json'
      resource = User.find_for_database_authentication(:email => params[:email])
      if resource.present?
        resource.send_reset_password_instructions
        render json: { message: "Password reset email sent", status: true }, status: 200
        return
      else
        render json: { message: "Invalid email", status: false }, status: 401
        return
      end
    else
      super
    end  
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?      
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active      
      sign_in(resource_name, resource)
      redirect_to '/profile?act=pwd'
    else    	
      respond_with resource
    end
  end

end  