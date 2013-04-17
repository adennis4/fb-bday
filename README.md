#Fbook AutoWish

###Automatically wishes happy birthday to friends.

Yeah - I'm too lazy to remember to visit fbook daily…AND I think wishing old acquaintances happy birthday is a nice thing to do. This takes care of that problem.  Oh yeah, and thanks to @jonallured - I also added a googled birthday image to the fbook message for good measure.

####Setup

  	git clone https://github.com/adennis4/fb-bday.git
	mv non_wish_list.example.rb non_wish_list.rb
	mv config.example.yml config.yml
	
######config.yml
	
	email: your_email@example.com
	password: YourPassword
	
######non_wish_list.rb

	def self.list
		[
		 "Guy I no longer talk to",
		 "Ex-girlfriend",
		 "Mom - I should call her"
		]
	end
	
####Run

	ruby birthday.rb

####MIT License
