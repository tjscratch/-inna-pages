# config valid only for current version of Capistrano
lock '3.6.0'

set :user, 'deploy'
set :use_sudo, true

set :pty, true
set :format, :pretty

set :application, 'InnaRails'
set :repo_url, 'ssh://git@gitlab.inna.ru:223/frontend-dev/inna-pages.git'
set :branch, 'master'
set :deploy_to, '/home/deploy/www/InnaRails'
set :shared_path, '/home/deploy/www/InnaRails/shared'
set :log_level, :info
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/uploads}

# set :rvm_type, :user                     # Defaults to: :auto
# set :rvm_ruby_version, '2.0.0-p247'      # Defaults to: 'default'
# set :rvm_custom_path, '~/.rvm'  # only needed if not detected


set :rvm_type, :user # Defaults to: :auto
# set :rvm_type, :auto
set :rvm_ruby_version, '2.3.1' # Defaults to: 'default'
# set :rvm_custom_path, '/usr/local/rvm' # only needed if not detected
set :rvm_custom_path, '/home/deploy/.rvm'  # only needed if not detected
set :rvm_roles, :all

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_init_active_record, true

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end


namespace :sidekiq do
  task :restart do
    on roles(:app) do
      execute :sudo, :service, :sidekiq, :restart, "index=0"
    end
  end
end

# after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'


# after 'deploy:starting', 'sidekiq:quiet'
# after 'deploy:reverted', 'sidekiq:restart'
# after 'deploy:published', 'sidekiq:restart'

# If you wish to use Inspeqtor to monitor Sidekiq
# https://github.com/mperham/inspeqtor/wiki/Deployments
# namespace :inspeqtor do
#   task :start do
#     on roles(:app) do
#       execute :inspeqtorctl, :start, :deploy
#     end
#   end
#   task :finish do
#     on roles(:app) do
#       execute :inspeqtorctl, :finish, :deploy
#     end
#   end
# end

# before 'deploy:starting', 'inspeqtor:start'
# after 'deploy:finished', 'inspeqtor:finish'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    # end
  # end
# end
