class CreateGuestUserSurveyTemplates < ActiveRecord::Migration
  def change
    create_table :guest_user_survey_templates do |t|
      t.integer  :survey_template_id
      t.integer  :guest_user_id
      t.string   :email_secure_token
      t.boolean  :accessed,           :default => false
      t.timestamps
    end
  end
end
