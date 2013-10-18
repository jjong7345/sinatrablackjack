require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do
  def calculate_total(cards)
    t = 0 
    # re-order cards array to push "A"s at the end
    temp = []
    temp2 = []
    cards.each do |c| 
      if (c != "A") ? (temp << c) : (temp2 << c)
      end
    end
    temp = temp.concat(temp2)

    arr = temp.map { |e| e[1] }

    arr.each do |c|
      if (c == "J") || (c == "Q") || (c == "K")
        t = t + 10
      elsif (c == "A")
        if ((t + 11) > 21) ? (t = t + 1) : (t = t +11)
        end
      else
        t = t + c.to_i
      end
    end
    return t 
  end
end

before do
  @hit_or_stay = true
end

get '/' do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/set_name"
  end
  erb :set_name
end

get "/set_name" do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get '/game' do
  session[:deck] = ["H", "D", "S", "C"].product(["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]).shuffle!

  session[:player_card] = []
  session[:dealer_card] = []
  2.times do  
    session[:player_card] << session[:deck].pop
    session[:dealer_card] << session[:deck].pop
  end
  erb :game
end

post "/player/hit" do 
  session[:player_card] << session[:deck].pop
  erb :game
end

post "/player/stay" do 
  @hit_or_stay = false
  erb :game
end



 