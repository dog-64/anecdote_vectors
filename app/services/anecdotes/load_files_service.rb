# Загрузка анекдотов
#  (33..2021).to_a.each {|j| puts j ; Anecdotes::LoadFilesService.call("./_src/bashorg/#{j}.html")  }
module Anecdotes
  class LoadFilesService < BaseService
    param :file_names, type: Types::Coercible::String

    def call
      html_files = Dir.glob(file_names)

      html_files.each do |file_path|
        # puts "#{__FILE__}:#{__LINE__} | #{file_path}"
        Anecdotes::LoadTextService.call(File.read(file_path))
      end
    end
  end
end
