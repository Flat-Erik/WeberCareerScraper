class DropPosts < ActiveRecord::Migration
  def up
	drop_table "posts"
  end

	def down
	  create_table "posts", force: true do |t|
	    t.string   "title"
    	t.text     "text"
	    t.datetime "created_at"
    	t.datetime "updated_at"
	  end
	end
end
