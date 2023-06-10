module PagesHelper
  def html(anecdote)
    words_2href(html_br(anecdote))
  end

  private

  def html_br(anecdote)
    anecdote['metadata']['html']
      .gsub(/(?:<br>){2,}/, '<br>')
      .gsub(/(?:<br>\n){2,}/, '<br>\n')
  end

  def words_2href(html)
    html
      .gsub /([А-яЁё]{3,})(?:\s+)([А-яЁё]{3,})/, '<a href=/?search=\1+\2>\1 \2</a>'
  end
end
