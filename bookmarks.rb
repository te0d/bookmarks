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

	get '/' do
	  @bookmarks = Bookmark.all

	  erb :index
	end

  post '/new' do
    bookmark = Bookmark.new

    bookmark.url = params[:url]
    bookmark.title = params[:title]
    bookmark.tags = params[:tags].split

    bookmark.save
    redirect '/'
  end
  
  get '/delete/:id' do |id|
    @bookmark = Bookmark.find(id)
    @bookmark.delete

    redirect '/'
  end
end
