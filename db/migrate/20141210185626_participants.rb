class Participants < ActiveRecord::Migration
  def change
  	create_table :participants do |t|
  		t.string :user_id, null: false
  		t.string :meetup_id, null: false
  	end
  end
end
