require 'rubygems'
require 'sinatra/base'
require 'mongoid'

class Bookmarks < Sinatra::Base
  Mongoid.load!('mongo.yml')

  class Bookmark
    include Mongoid::Document

    field :url, type: String
    field :title, type: String
    has_and_belongs_to_many :tags
  end

  class Tag
    include Mongoid::Document

    field :name, type: String
    has_and_belongs_to_many :bookmarks
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
    @tags = Tag.all.sort_by { |t| t.name }

    erb :index
  end

  post '/new' do
    protected!

    bookmark = Bookmark.new
    bookmark.url = params[:url]
    bookmark.title = params[:title]
    bookmark.save

    tag_names = params[:tags].split
    tag_names.each do |name|
      tag = Tag.find_or_create_by(name: name)
      bookmark.tags.push(tag)
    end

    redirect '/'
  end
  
  get '/delete/:id' do |id|
    protected!

    @bookmark = Bookmark.find(id)
    @bookmark.delete

    redirect '/'
  end

  get "/tags/:name" do |name|
    @bookmarks = Tag.find_by(name: name).bookmarks
    @tags = Tag.all.sort_by { |t| t.name }

    erb :index
  end
end
