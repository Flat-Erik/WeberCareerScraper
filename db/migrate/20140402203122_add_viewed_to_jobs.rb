class AddViewedToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :viewed, :boolean
  end
end
