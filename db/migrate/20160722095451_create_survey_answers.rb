class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.text   :answer
      t.integer :survey_question_id
      t.integer  :option_id
      t.integer  :user_survey_template_id
      t.integer  :guest_user_survey_template_id
      t.timestamps
    end
  end
end
