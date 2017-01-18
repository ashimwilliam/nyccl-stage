class ChangeCampaignPpcBody < ActiveRecord::Migration
  def up
  	change_column :campaign_ppcs, :body, :text
  end

  def down
  end
end
