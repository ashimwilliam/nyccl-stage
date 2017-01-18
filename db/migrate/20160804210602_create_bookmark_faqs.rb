class CreateBookmarkFaqs < ActiveRecord::Migration
  def change
    create_table :bookmark_faqs do |t|
      t.integer :user_id
      t.integer :faq_id

      t.timestamps
    end
  end
end
