class PagesController < ApplicationController
  def index
    search
  end

  # def create
  #   redirect_to root_path(search:, anecdotes:)
  # end

  private

  def search
    @search ||= params.to_unsafe_h.fetch(:search, '')
  end

  def anecdotes
    @anecdotes ||= Anecdotes::SearchService.call(search)
  end
end
