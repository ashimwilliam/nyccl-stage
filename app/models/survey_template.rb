require 'securerandom'
class SurveyTemplate < ActiveRecord::Base

  
  attr_accessible :title, :status_id, :identifier,:secure_token,:description, :send_date, :user_type, :survey_template_questions_attributes
  before_create :generate_secure_token

  has_many :survey_template_questions, dependent: :destroy
  has_many :survey_questions, through: :survey_template_questions

  has_many :user_survey_templates, dependent: :destroy
  has_many :users, through: :user_survey_templates

  has_many :guest_user_survey_templates, dependent: :destroy
  has_many :guest_users, through: :guest_user_survey_templates

  accepts_nested_attributes_for :survey_template_questions, allow_destroy: true
 # accepts_nested_attributes_for :survey_answers, allow_destroy: true

  def generate_secure_token
  	self.secure_token =  SecureRandom.hex(3)
  end

end
