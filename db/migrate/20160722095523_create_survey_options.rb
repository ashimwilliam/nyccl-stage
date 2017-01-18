class CreateSurveyOptions < ActiveRecord::Migration
  def change
    create_table :survey_options do |t|
      t.integer  :survey_question_id
      t.string   :option_title
      t.timestamps
    end
  end
end
