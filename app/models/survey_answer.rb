class SurveyAnswer < ActiveRecord::Base
  attr_accessible :answer, :survey_question_id, :user_id, :survey_template_id, :user_survey_templates_id

  belongs_to :survey_question
  belongs_to :user_survey_template
  belongs_to :guest_user_survey_template
end
