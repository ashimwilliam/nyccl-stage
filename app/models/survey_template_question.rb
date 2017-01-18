class SurveyTemplateQuestion < ActiveRecord::Base
  attr_accessible :survey_question_id, :survey_template_id, :order
  
  belongs_to :survey_question
  belongs_to :survey_template

  
end
