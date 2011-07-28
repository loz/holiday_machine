#set :application, "holiday_machine"
#set :scm, :git
##set :domain, "thalamouse.com"
#set :repository, "git://github.com/etskelly/#{application}.git"
#set :scm_username, "etskelly"
#set :user, "root"
##set :use_sudo, false
#set :deploy_to, "/webapps/#{application}"
#
#server "thalamouse.com", :app, :web, :db, :primary => true
#
#
##ssh_options[:forward_agent] = true
#set :branch, "master"
#
#set :deploy_via, :remote_cache
#
#
#role :app, domain
#role :web, domain
#role :db, domain, :primary => true
#
#namespace :deploy do
#  task :start, :roles => :app do
#    run "touch #{current_release}/tmp/restart.txt"
#  end
#
#  task :stop, :roles => :app do
#    # Do nothing.
#  end
#
#  desc "Restart Application"
#  task :restart, :roles => :app do
#    run "touch #{current_release}/tmp/restart.txt"
#  end
#end

# RVM

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
set :repository,  "git://github.com/etskelly/holiday_machine.git"
set :branch, "master"

# VPS
#TODO change port?
role :web, "109.123.110.139"
role :app, "109.123.110.139"
role :db,  "109.123.110.139", :primary => true
role :db,  "109.123.110.139"

# Passenger
namespace :deploy do
 task :start do ; end
 task :stop do ; end
 task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
 end
end
