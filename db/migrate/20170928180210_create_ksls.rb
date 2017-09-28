class CreateKsls < ActiveRecord::Migration
  def change
    create_table :ksls do |t|
      t.string :name
      t.string :link
      t.string :org
      t.boolean :viewed
      t.boolean :deleted

      t.timestamps
    end
  end
end
