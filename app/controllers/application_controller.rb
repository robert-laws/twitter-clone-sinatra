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
    if logged_in?
      redirect to "/tweets"
    else
      erb :'users/login'
    end
  end

  post "/login" do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      userslug = @user.slug
      redirect to "/tweets"
    else
      redirect to "/login"
    end
  end

  get "/signup" do
    if logged_in?
      redirect to "/tweets"
    else
      erb :'users/create_user'
    end
  end

  post "/signup" do
    if params[:username] == "" || params[:email] == "" || params[:password] == ""
      redirect to "/signup"
    else
      user = User.new(username: params[:username], email: params[:email], password: params[:password])
      
      if user.save
        session[:user_id] = user.id
        redirect to "/tweets"
      else
        redirect to "/signup"
      end
    end    
  end

  get "/tweets" do
    if logged_in?
      @user = current_user
      @tweets = Tweet.all
      erb :'tweets/tweets'
    else
      redirect to "/login"
    end
  end

  get "/tweets/new" do
    if logged_in?
      erb :'tweets/create_tweet'
    else
      redirect to "/login"
    end
  end

  post "/tweets/new" do
    if params[:content] == ""
      redirect to "/tweets/new"
    else
      @user = current_user
      @tweet = Tweet.create(content: params[:content])
      @user.tweets << @tweet
    end
  end

  get "/logout" do
    session.clear
    redirect to "/login"
  end

  get "/users/:slug" do
    @user = current_user
    @tweets = @user.tweets
    erb :'users/show'
  end

  get "/tweets/:id" do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      erb :'tweets/show_tweet'
    else
      redirect to "/login"
    end
  end

  get "/tweets/:id/edit" do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      erb :'tweets/edit_tweet'
    else
      redirect to "/login"
    end
  end

  post "/tweets/:id/edit" do
    if params[:content] == ""
      redirect to "/tweets/#{params[:id]}/edit"
    else
      @tweet = Tweet.find(params[:id])
      @tweet.update(content: params[:content])
    end
  end

  delete "/tweets/:id/delete" do
    @tweet = Tweet.find_by_id(params[:id])
    @user = current_user
    if @tweet.user_id == @user.id
      @tweet.delete
    else
      redirect to '/tweets'
    end
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