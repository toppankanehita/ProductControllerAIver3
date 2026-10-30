class CreatePaperTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :paper_types do |t|
      t.string :category
      t.string :type

      t.timestamps
    end
  end
end
