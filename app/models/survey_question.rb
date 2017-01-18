class SurveyQuestion < ActiveRecord::Base

  QUESTION_TYPES = {
    'True/False' => 1,
    'Single Select Answer'=> 2,
    'Multiple Select Answer' => 3,
    'Detail Answer' => 4,
  }	
   
  attr_accessible :question_title, :ques_help, :question_type, :required, :survey_options_attributes
  
  validates_presence_of :question_title, :question_type
 
  has_many :survey_options, dependent: :destroy
  has_many :survey_answers, dependent: :destroy

  accepts_nested_attributes_for :survey_options, allow_destroy: true
  
  has_many :survey_template_questions, dependent: :destroy
  has_many :survey_templates, through: :survey_template_questions

end
