class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :name
      t.text :link
      t.string :job_id
      t.string :org

      t.timestamps
    end
  end
end
