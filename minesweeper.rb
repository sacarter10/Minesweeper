#!/usr/bin/env ruby

require 'yaml'
require 'colorize'
require './tile.rb'
require './board.rb'

class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
  end

  def click_square(pos)
    if @board[pos].bomb?
      @board.reveal_all
      puts "You lost!"
      puts @board
    elsif @board.won?
      puts "You Won!"
      @board.reveal_all
      puts @board
    else
      @board.reveal_neighbors(pos)
    end
  end
  
  def get_input_string(input)
    return input.first if input.length == 3
  end

  def play
    welcom_message

    until @board.won?
      puts @board
      input = get_input
      
      return if input.first.downcase == 'quit'
      
      if input.first.downcase == 'save'
        save_game
        puts "Game saved!"
        return
      end
 
      play_turn(input)
    end
  end

  def get_coordinates(input)
    pos = input.length == 3 ? input[-2..-1] : input
    pos.map(&:to_i)
  end
  
  def get_input
    puts ("=" * 34).colorize(:blue)
    puts "Type x y to click square (ex. 3 1)".colorize(:magenta)
    puts "or type 'F x y' to flag a position".colorize(:magenta)
    input = gets.chomp.split(' ')
    
    until valid_move?(input)
      puts "Not a valid move; please try again!".colorize(:magenta)
      input = gets.chomp.split(' ')
    end

    input
  end

  def self.load(file)
    file_contents = File.read(file)
    game = YAML.load(file_contents)
    game.play
  end

  def play_turn(input)
    if input.length == 2
      click_square(get_coordinates(input))
    else
      @board[get_coordinates(input)].toggle_flag
    end
  end

  def save_game
    File.open("#{DateTime.now.strftime("%a-%b-%e-%H-%M-%S")}", 'w') do |f|
      f.puts self.to_yaml
    end
  end
  
  def valid_move?(input)
    leave_game = (input.first == 'quit' || input.first == 'save')
    return input if leave_game
    coordinates = get_coordinates(input)
    (2..3).include?(input.length) &&
    @board.on_board?(coordinates) &&
    @board[coordinates].hidden? 
  end
  
  def welcom_message
    puts ("=" * 34).colorize(:blue)
    puts "Welcome to Minesweeper!".colorize(:magenta)
    puts "To save your game, enter 'save.'".colorize(:magenta)
    puts ("=" * 34).colorize(:blue)
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Minesweeper.new
  game.play
end