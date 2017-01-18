class CreateSurveyTemplates < ActiveRecord::Migration
  def change
    create_table :survey_templates do |t|
      t.string   :title
      t.text     :description
      t.string   :identifier
      t.date     :send_date
      t.string   :user_type
      t.integer  :status_id,    :default => 1
      t.integer  :creator_id
      t.string   :secure_token
      t.timestamps
    end
  end
end
