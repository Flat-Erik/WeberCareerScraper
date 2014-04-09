class AddDeletedToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :deleted, :boolean
  end
end
