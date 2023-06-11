# frozen_string_literal: true

# rake carriages:update
namespace :anecdotes do
  desc 'Обновление данных обо всех перевозках из API Ozon'
  task load: :environment do
    puts 'anecdotes::load boj'

    page_number = rand(1..2021)
    puts "#{__FILE__}:#{__LINE__} | page_number=#{page_number.inspect}"

    updates =  Anecdotes::LoadService.call(page_number)
    puts "#{__FILE__}:#{__LINE__} | updates=#{updates.inspect}"

    puts 'anecdotes::load eoj'
  end
end
