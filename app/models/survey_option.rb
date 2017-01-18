class SurveyOption < ActiveRecord::Base
  attr_accessible :survey_question_id, :option_title

  belongs_to :survey_question

  
end
