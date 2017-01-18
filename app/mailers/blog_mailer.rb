class BlogMailer < ActionMailer::Base
  CONFIG = YAML.load_file("#{Rails.root}/config/nyccollegeline.yml")[Rails.env]
  LOGO = File.read(Rails.root.join('app/assets/images/emails/logo.png')) 
  default from: CONFIG['mail_sender']

  def notification_email(blog, user)
  	@blog = blog
  	@user = user
  	attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/emails/logo.png'))
    mail(
      to: @user.email,
      subject: @blog.title,
      from: CONFIG['mail_sender'],
    )do |format|
      format.html { render layout: 'email' }
    end
    
  end

end	

