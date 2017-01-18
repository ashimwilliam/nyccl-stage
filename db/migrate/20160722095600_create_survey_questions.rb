class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.string   :question_title
      t.string   :ques_help
      t.integer  :question_type
      t.boolean  :required
      t.timestamps
    end
  end
end
