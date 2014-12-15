require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

# index page - returns all meetups in the database
get '/' do
  meetups = Meetup.all
  @meetups = meetups.order(:name)
  # binding.pry
  erb :index
end

# give us detail on one selected meetup
get '/meetups/:id' do
  
  @user = session[:id]
  @meetup = Meetup.find(params[:id])
  
  erb :show
end

# get us to the page to create a new meetup
get '/create_meetup' do
  

  erb :create_meetup
end


get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  if user.save != true
    user.save
  end
  set_current_user(user)

  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

# to create a new meetup
post '/create_meetup' do
  
  @name = params[:new_name]
  @location = params[:new_location]
  @description = params[:new_description]
  
  new_meetup = Meetup.new(name: @name, location: @location, description: @description)
  # need to validate that a user is signed in before saving the new record
  if current_user 
    new_meetup.save
  end

  if new_meetup.save == true
    flash "You have successfully added your new Meetup!"
  else
    flash "there has been an error adding your Meetup"
  end

  # binding.pry

  # need to redirect to the actual page of the meetup - is not working currently
  redirect '/'

end

# Leaving a meetup working.
post '/meetups/' do
  
  join_meetup = params[:join_meetup]
  
  new_participant = Participant.new(user_id: session[:user_id], meetup_id: join_meetup) 
  # binding.pry
  # need to add a conditional that will make sure the user isn't joining twice
  new_participant.save

  redirect "/meetups/#{join_meetup}"
end


# Still not quite working.
post '/meetups/leave' do
  # binding.pry
  leave_meetup = Participant.find_by(user_id: params[:user_leave], meetup_id: meetup_leave)
  # binding.pry
  leave_meetup.destroy
  # flash "you have left the meetup!"
  redirect "/"

end

