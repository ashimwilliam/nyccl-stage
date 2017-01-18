class CreateSurveyTemplateQuestions < ActiveRecord::Migration
  def change
    create_table :survey_template_questions do |t|
      t.integer  :survey_template_id
      t.integer  :survey_question_id
      t.timestamps
    end
  end
end
