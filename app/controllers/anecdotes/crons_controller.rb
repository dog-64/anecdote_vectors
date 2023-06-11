# https://www.easycron.com/user
class Anecdotes::CronsController < ApplicationController
  before_action :token?

  def index
    puts 'anecdotes::load boj'

    page_number = rand(1..2021)
    puts "#{__FILE__}:#{__LINE__} | page_number=#{page_number.inspect}"

    updates = Anecdotes::LoadService.call(page_number)
    puts "#{__FILE__}:#{__LINE__} | updates=#{updates.inspect}"

    puts 'anecdotes::load eoj'
  end

  def token?
    return unless params.to_unsafe_h[:token] == 'weuqryqwieuypqwed'

    true
  end
end
