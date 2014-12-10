class Participant < ActiveRecord::Base
	has_many :users
	has_many :meetups
end
