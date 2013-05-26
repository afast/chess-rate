class Tournament < ActiveRecord::Base
  attr_accessible :end_date, :name, :site_id, :start_date

  belongs_to :site
end
