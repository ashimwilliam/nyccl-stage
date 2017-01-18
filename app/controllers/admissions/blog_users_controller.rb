class Admissions::BlogUsersController < ApplicationController

  def index
    @blog_users = BlogUser.paginate(page: params[:page], per_page: @per_page || params[:per_page])  
      respond_to do |format|
        format.html {render layout: 'admissions/layouts/application'}
      end  
  end


  def new
  end

  def create

  	@blog_user = BlogUser.new(email: params[:blog_user][:email])
  	if @blog_user.save
  		redirect_to :back, notice: "You have successfully subscribed to Blog email notification."
  	else
  		redirect_to blog_posts_path, notice: "You have been already subscribed to this."
    end		
  end

  def confirm_destroy
    @blog_user = BlogUser.find(params[:id])
     respond_to do |format|
        format.html {render layout: 'admissions/layouts/application'}
      end 
  end  

  def destroy
    @blog_user = BlogUser.find(params[:id])
    @blog_user.destroy
    redirect_to admin_blog_users_path, notice: "User has been sucessfully deleted"
     
  end

  def export_csv
    
    respond_to do |format|
      format.csv {
        send_data BlogUser.export_csv,
                  type: 'text/csv; charset=iso-8859-1; header=present',
                  disposition: "attachment; filename=blog_user-#{DateTime.now}.csv"
      }
    end
    
  end


end
