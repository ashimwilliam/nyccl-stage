class ChangeLayoutToCampaignPpc < ActiveRecord::Migration
  def up
    add_column :campaign_ppcs, :layout, :integer
  end

  def down
  end
end
