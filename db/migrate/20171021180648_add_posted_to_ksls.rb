class AddPostedToKsls < ActiveRecord::Migration
  def change
    add_column :ksls, :posted, :date
  end
end
