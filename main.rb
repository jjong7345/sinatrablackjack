require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do
  def calculate_total(cards)
    55
  end
end
get '/' do
  erb :set_name
end

post '/set_name' do
  #binding.pry
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get '/game' do
  session[:deck] = [['2','H'], ['3','D']]
  session[:player_card] = []
  session[:player_card] << session[:deck].pop
  erb :game
end


 