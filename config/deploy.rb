$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, 'default'
set :rvm_type, :user

# Bundler
require "bundler/capistrano"

# General
set :application, "holiday_machine"
set :user, "etskelly"

set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :copy

set :use_sudo, false

# Git
set :scm, :git
set :repository, "git://github.com/etskelly/holiday_machine.git"
set :branch, "master"

set :gateway, '109.123.110.23:22'

# VPS
#TODO change port?
role :web, "109.123.110.23:22"
role :app, "109.123.110.23:22"
role :db, "109.123.110.23:22", :primary => true

# Passenger
namespace :deploy do
  task :start do
    ;
  end
  task :stop do
    ;
  end
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end
  task :rebuild do
    run "cd #{current_path}; bundle install; rake db:reset RAILS_ENV=production"
  end
  task :migrate do
    run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
  end
end
