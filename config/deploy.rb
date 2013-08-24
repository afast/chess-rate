require "bundler/capistrano"
load "deploy/assets"

default_run_options[:pty] = true
set :application, "chess_rate"
set :repository,  "git@github.com:afast/chess-rate.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :ssh_options, {keys: ["/home/andreas/afast"], forward_agent: true}

set :user, "afast"
set :use_sudo, false
set :scm_passphrase, "eliseo"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :branch, "server"
server "ec2-54-213-7-243.us-west-2.compute.amazonaws.com", :app, :web, :db, :primary => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy:update_code', 'deploy:migrate'
set :keep_releases, 5
after 'deploy', 'deploy:cleanup'

# you can comment out any recipe if you don't need it
require "capistrano-rails-server/recipes/base"
require "capistrano-rails-server/recipes/nginx"
require "capistrano-rails-server/recipes/unicorn"
require "capistrano-rails-server/recipes/rbenv"
require "capistrano-rails-server/recipes/check"
