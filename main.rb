# frozen-string-literal: true

#
# TODO:
# !c4restart (admin permissions required)
# status thing

require 'discordrb'
require_relative 'game.rb'
require_relative 'player.rb'

config = File.foreach('config.txt').map { |line| line.split(' ').join(' ') }
TOKEN = config[0].to_s
ID = config[1].to_s
PREFIX = %w[!c4 !connect4].freeze
LOG_MODE = :silent

bot = Discordrb::Commands::CommandBot.new token: TOKEN, client_id: ID, prefix: PREFIX, max_args: 1, log_mode: LOG_MODE

BOTS_ALLOWED = true
NUMBER_CODES = %w[1⃣ 2⃣ 3⃣ 4⃣ 5⃣ 6⃣ 7⃣].freeze

def add_reactions(msg)
  7.times do |num|
    msg.react(NUMBER_CODES[num])
  end
  nil # it does msg.respond with the return value of this method for some reason
end

bot.ready do
  puts 'Bot connected successfully'
  bot.update_status('online', '!c4help', nil)
end

# !c4play <target>, start a game against another member
bot.command :play, description: 'Start a game against someone', min_args: 1 do |msg|
  break unless msg.server

  target_name = msg.content[(msg.content.index(' ') + 1)..-1]
  target = msg.server.members.select { |member| member.display_name.downcase == target_name.downcase }[0]

  if Game.locate_player(msg.author)
    msg.respond("You're already in a game")
  elsif !target
    msg.respond("Couldn't find that person")
  elsif Game.locate_player(target)
    msg.respond("They're already in a game")
  elsif target == msg.author
    msg.respond("You can't play yourself")
  elsif !BOTS_ALLOWED && (target.bot_account? || msg.author.bot_account?)
    msg.respond("Bots can't play")
  elsif target == bot.bot_user
    msg.respond("You can't play the bot")
  else
    game = Game.new(msg.author, target)
    color = ":#{game.p1.color}_circle:"
    add_reactions(msg.respond("#{msg.author.mention}'s turn: #{color}\n\n#{game.stringify_board}"))
  end
end

# !c4move <column>, make a move during a game in a certain column
bot.command :move, description: 'Make a move during a game', min_args: 1 do |msg|
  break unless msg.server

  col = msg.content.split[1].to_i - 1
  # get the Player object for the author so we can figure out which game it is
  player = Game.locate_player(msg.author)
  if !player
    msg.respond("You're not in a game")
  elsif col.negative? || col.digits.count > 1 || col > 6
    msg.respond('Invalid input')
  else
    game = player.game
    if game.whose_turn != player
      msg.respond('Not your turn')
    elsif game.check_col_full?(col)
      msg.respond('Illegal move')
    else
      player.make_move(col)
      if game.check_win?
        game.end_game
        msg.respond("#{player.name} wins!\n\n#{game.stringify_board}")
      elsif game.check_board_full?
        game.end_game
        msg.respond("Tie!\n\n#{game.stringify_board}")
      else
        color = ":#{game.whose_turn.color}_circle:"
        add_reactions(msg.respond("#{game.whose_turn.user.mention}'s turn: #{color}\n\n#{game.stringify_board}"))
      end
    end
  end
end

# !c4resign, end game prematurely
bot.command :resign, description: "Resign the game you're currently playing", max_args: 0 do |msg|
  break unless msg.server

  player = Game.locate_player(msg.author)
  if !player
    msg.respond("You're not in a game")
  else
    game = player.game
    game.end_game
    win_message = "#{player == game.p1 ? game.p2.name : game.p1.name} wins!\n"
    msg.respond("#{win_message}#{player.user.mention} has resigned the game between #{game.p1.name} and #{game.p2.name}.")
  end
end

bot.reaction_add do |evt|
  break unless evt.message.author == bot.bot_user

  evt.message.delete_reaction(evt.user, evt.emoji.to_s)
  user_id = evt.message.content[2...(evt.message.content.index('>'))].to_i
  break unless evt.user.id == user_id && NUMBER_CODES.include?(evt.emoji.to_s)

  col = NUMBER_CODES.index(evt.emoji.to_s)
  player = Game.locate_player(evt.user)
  break unless player

  game = player.game
  break if game.whose_turn != player

  if game.check_col_full?(col)
    evt.message.respond('Illegal move')
  else
    player.make_move(col)
    if game.check_win?
      game.end_game
      evt.message.respond("#{player.name} wins!\n\n#{game.stringify_board}")
    elsif game.check_board_full?
      game.end_game
      evt.message.respond("Tie!\n\n#{game.stringify_board}")
    else
      color = ":#{game.whose_turn.color}_circle:"
      add_reactions(evt.message.respond("#{game.whose_turn.user.mention}'s turn: #{color}\n\n#{game.stringify_board}"))
    end
  end
end

at_exit { bot.stop }
bot.run
