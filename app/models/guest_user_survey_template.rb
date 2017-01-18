class GuestUserSurveyTemplate < ActiveRecord::Base
  attr_accessible :survey_template_id, :guest_user_id, :email_secure_token, :accessed
  
  belongs_to :guest_user
  belongs_to :survey_template
  has_many :survey_answers,  dependent: :destroy
  
end
