# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ChessRate::Application.initialize!

# set per_page globally
WillPaginate.per_page = 10
