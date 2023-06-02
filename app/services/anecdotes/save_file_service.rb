# Сохранение страницы анекдота в файл
#  (1..2021).to_a.each {|j| puts j ; Anecdotes::SaveFileService.call(j, './_src/bashorg') ; sleep rand(60) }
module Anecdotes
  class SaveFileService < BaseService
    param :page_number, type: Types::Coercible::Integer
    param :dir_name, type: Types::Coercible::String

    def call
      url = "http://bashorg.org/page/#{page_number}/"
      html = URI.open(url)
      doc = Nokogiri::HTML(html, "UTF-8")
      File.write("#{dir_name}/#{page_number}.html", doc.to_html)
    end
  end
end
