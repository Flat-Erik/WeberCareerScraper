class DropComments < ActiveRecord::Migration
  def up
	drop_table "comments"
  end

	def down
		  create_table "comments", force: true do |t|
		    t.string   "commenter"
		    t.text     "body"
		    t.integer  "post_id"
		    t.datetime "created_at"
		    t.datetime "updated_at"
		  end
		 add_index "comments", ["post_id"], name: "index_comments_on_post_id"
	end
end
