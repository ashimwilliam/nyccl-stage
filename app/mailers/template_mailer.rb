class TemplateMailer < ActionMailer::Base
  CONFIG = YAML.load_file("#{Rails.root}/config/nyccollegeline.yml")[Rails.env]
  LOGO = File.read(Rails.root.join('app/assets/images/emails/logo.png')) 
  default from: CONFIG['mail_sender']

  def template_mail(user_survey_template)
    @user_survey_template = user_survey_template
    @user = User.find(@user_survey_template.user_id) 
    @survey_template = SurveyTemplate.find(@user_survey_template.survey_template_id)
    @sender = User.find(@survey_template.creator_id)
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/emails/logo.png'))
    mail(
      to: @user.email,
      subject: @survey_template.title,
      from: "NYC College Line <no-reply@nyccollegeline.org>",
    )
  end

  def guest_user_template_mail(guest_user_survey_template)
    @guest_user_survey_template = guest_user_survey_template
    @guest_user = GuestUser.find(@guest_user_survey_template.guest_user_id) 
    @survey_template = SurveyTemplate.find(@guest_user_survey_template.survey_template_id)
    @sender = User.find(@survey_template.creator_id)
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/emails/logo.png'))
    mail(
      to: @guest_user.email,
      subject: @survey_template.title,
      from: "NYC College Line <no-reply@nyccollegeline.org>",
    )    
  end

end
