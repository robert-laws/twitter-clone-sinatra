require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, 'password_security'
  end

  get "/users/error" do
    erb :'users/error'
  end

  get "/" do
    erb :index
  end

  get "/login" do
    erb :'users/login'
  end

  post "/login" do
    @user = User.find_by(username: params[:username], email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      userslug = @user.slug
      redirect to "/users/#{userslug}"
    else
      redirect to "/users/error"
    end
  end

  get "/signup" do
    erb :'users/create_user'
  end

  post "/signup" do
    user = User.new(username: params[:username], email: params[:email], password: params[:password])

    if user.save
      session[:user_id] = user.id
      redirect to "/"
    else
      redirect to "/users/error"
    end
  end

  get "/logout" do
    session.clear
    erb :index
  end

  get "/users/:slug" do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end