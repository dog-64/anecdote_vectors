class PagesController < ApplicationController
  def index
    @anecdote = ""
  end

  def create
    @anecdote = params[:anecdote]
    render :index
  end
end
