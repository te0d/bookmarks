require 'rubygems'
require 'sinatra/base'
require 'mongoid'

class Bookmarks < Sinatra::Base
  Mongoid.load!('mongo.yml')

  class Bookmark
    include Mongoid::Document

    field :url, type: String
    field :title, type: String
    field :tags, type: Array
  end

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['CLOUD_USER'], ENV['CLOUD_PASS']]
    end
  end

  get '/' do
    @bookmarks = Bookmark.all

    erb :index
  end

  post '/new' do
    protected!

    bookmark = Bookmark.new
    bookmark.url = params[:url]
    bookmark.title = params[:title]
    bookmark.tags = params[:tags].split

    bookmark.save
    redirect '/'
  end
  
  get '/delete/:id' do |id|
    protected!

    @bookmark = Bookmark.find(id)
    @bookmark.delete

    redirect '/'
  end
end
