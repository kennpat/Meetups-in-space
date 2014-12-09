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
  @meetups = Meetup.all
  # binding.pry
  erb :index
end

# give us detail on one selected meetup
get '/meetups/:id' do
  # @id = params[:id]
  binding.pry
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
  if helpers.current_user && helplers.signed_in? 
    new_meetup.save
  end

  if new_meetup.save == true
    flash "You have successfully added your new Meetup!"
  else
    flash "there has been an error adding your Meetup"
  end

  binding.pry

  # need to redirect to the actual page of the meetup - is not working currently
  redirect '/'

end

# to post a comment on a meetup
post '/meetups/:id' do

end


