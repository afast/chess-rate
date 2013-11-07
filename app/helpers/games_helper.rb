module GamesHelper
  def humanize_result(result)
    case result
    when '1/2-1/2'
      t('draw')
    when '1-0'
      t('white')
    when '0-1'
      t('black')
    else
      result
    end
  end
end
