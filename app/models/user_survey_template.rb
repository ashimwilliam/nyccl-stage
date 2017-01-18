class UserSurveyTemplate < ActiveRecord::Base
  attr_accessible :survey_template_id, :user_id, :email_secure_token, :accessed
  
  belongs_to :user
  belongs_to :survey_template
  has_many :survey_answers, dependent: :destroy

end
