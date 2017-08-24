require 'sinatra'
require 'sinatra/namespace'
require 'json'
require 'mongoid'

set :environment, :production
set :port, 8080

Mongoid.load! "mongoserver.config"

class Drink
  include Mongoid::Document

  field :name, type: String
  field :price, type: String
  field :sku, type: String

  validates :name, presence: true
  validates :price, presence: true
  validates :sku, presence: true

  index({ name: 'text' })
  index({ sku:1 }, { unique: true, name: "sku_index" })

  scope :name, -> (name) { where(name: /^#{name}/) }
  scope :price, -> (price) { where(price: price) }
  scope :sku, -> (sku) { where(sku: sku) }
end

class DrinkFormatter
  def initialize(drink)
    @drink = drink
  end

  def as_json(*)
    data = {
      id:@drink.id.to_s,
      name:@drink.name,
      price:@drink.price,
      sku:@drink.sku
    }
    data[:errors] = @drink.errors if@drink.errors.any?
    data
  end
end


get '/' do
  'Welcome to starbucks'
end

namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://{request.env['HTTP_HOST']}"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message:'Invalid JSON' }.to_json
      end
    end
  end

  get '/drinks' do
    drinks = Drink.all

    [:name, :price].each do |filter|
      drinks = drinks.send(filter, params[filter]) if params[filter]
    end

    drinks.map { |drink| DrinkFormatter.new(drink) }.to_json
  end

  get '/drinks/:id' do |id|
    drink = Drink.where(id: id).first
    halt(404, { message:'Drink Not Found YO!'}.to_json) unless drink
    DrinkFormatter.new(drink).to_json
  end

  post '/drinks' do
    drink = Drink.new(json_params)
    if drink.save
      response.headers['Location'] = "#{base_url}/api/v1/drinks/#{drink.id}"
      status 201
    else
      status 422
      body DrinkFormatter.new(drink).to_json
    end
  end

  patch '/drinks/:id' do |id|
    drink = Drink.where(id: id).first
    halt(404, { message:'Drink Not Found PATCH'}.to_json) unless drink
    if drink.update_attributes(json_params)
      DrinkFormatter.new(drink).to_json
    else
      status 422
      body DrinkFormatter.new(drink).to_json
    end
  end

  delete '/drinks/:id' do |id|
    drink = Drink.where(id: id).first
    drink.destroy if drink
    status 204
  end

end

