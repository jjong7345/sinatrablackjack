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
end

get "/set_name" do
  session[:player_money] = 500
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:set_name)
  end

  session[:player_name] = params[:player_name]
  redirect "/bet"
end

get "/bet" do
  session[:player_bet] = nil
  erb :bet
end

post "/bet" do 
  if params[:bet_amount] == nil || params[:bet_amount].to_i < 0
    @error ="Please, enter amount greater than $0"
    halt erb :bet
  elsif params[:bet_amount].to_i > session[:player_money]
    @error = "Bet exceeds player's total money"
    halt erb :bet
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect "/game"
  end
end

get '/game' do
  session[:deck] = ["H", "D", "S", "C"].product(["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]).shuffle!

  session[:player_card] = []
  session[:dealer_card] = []
  2.times do  
    session[:player_card] << session[:deck].pop
    session[:dealer_card] << session[:deck].pop
  end

  if (calculate_total(session[:player_card]) == 21)
    @success = session[:player_name] + " wins! " + session[:player_name] + " has BlackJack!"
    session[:player_money] = session[:player_money] + session[:player_bet]
  end

  erb :game
end

post "/player/hit" do 
  session[:player_card] << session[:deck].pop

  if (calculate_total(session[:player_card]) == 21)
    @success = session[:player_name] + " wins! " + session[:player_name] + " has BlackJack!"
    @hit_or_stay = false
    @play_again = true
    session[:player_money] = session[:player_money] + session[:player_bet]
  elsif (calculate_total(session[:player_card]) > 21) 
    @error = session[:player_name] + " busted! " + session[:player_name] + " lost!"
    @hit_or_stay = false
    @play_again = true
    session[:player_money] = session[:player_money] - session[:player_bet]
  end

  erb :game, layout:false
end

post "/player/stay" do 
  @hit_or_stay = false
  @success = "Now, It is dealer's turn"
  redirect '/dealer'
  erb :game
end

get "/dealer" do
  @hit_or_stay = false
  if (calculate_total(session[:dealer_card]) == 21) 
    @error = "Dealer wins!! Dealer has BlackJack!!"
    @play_again = true
    session[:player_money] = session[:player_money] - session[:player_bet]
  elsif (calculate_total(session[:dealer_card]) > 16) && (calculate_total(session[:dealer_card]) <= 21)
    @hit_or_stay = false
    @play_again = true
    redirect "/result"
  else
    @dealer_hit = true
  end
  erb :game
end

post "/dealer/hit" do 
  session[:dealer_card] << session[:deck].pop
  @dealer_hit = false
  if (calculate_total(session[:dealer_card]) > 16) && (calculate_total(session[:dealer_card]) <= 21)
    @hit_or_stay = false
    @play_again = true
    redirect "/result"
  elsif calculate_total(session[:dealer_card]) > 21 
    @success = "Dealer busted! " + session[:player_name] + " wins!"
    @hit_or_stay = false
    @play_again = true
    session[:player_money] = session[:player_money] + session[:player_bet]
  else
    @dealer_hit = true
  end

  erb :game
end

get "/result" do
  if calculate_total(session[:player_card]) > calculate_total(session[:dealer_card])
    @success = session[:player_name] + " wins!"
    session[:player_money] = session[:player_money] + session[:player_bet]
  elsif calculate_total(session[:player_card]) < calculate_total(session[:dealer_card])
    @error = session[:player_name] + " loses"
    session[:player_money] = session[:player_money] - session[:player_bet]
  else
    @success = "draw!"
  end
  @hit_or_stay = false
  @play_again = true
  @dealer_hit = false
  erb :game
end

get '/game_over' do
  erb :game_over
end






 