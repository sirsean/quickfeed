require "bundler/capistrano"
require "rvm/capistrano"

set :application, "quickfeed"
set :user, "quickfeed"
set :deploy_to, "/home/#{user}/#{application}"

require "capistrano-unicorn"

set :use_sudo, false

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :rvm_type, :system

set :repository, "git@github.com:sirsean/quickfeed.git"
set :branch, "master"
set :scm, :git
set :deploy_via, :remote_cache

server "feedhammer.com", :app, :web, :db, :primary => true

set :ssh_options, { :forward_agent => true }

after "deploy", "deploy:migrate"
