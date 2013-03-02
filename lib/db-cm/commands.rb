require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"
require "terminal-table"
require "yaml"

module Db
  module Cm
    class Commands < Thor
      include Thor::Actions

      def self.source_root
        File.dirname(__FILE__)
      end
      
      desc "init APP_NAME", "Initializes the directory structure"
      def init(app_name)
        app_root = File.join(self.destination_root, app_name)
        empty_directory app_root
        self.destination_root = app_root
          
        empty_directory 'environments'
        empty_directory 'bootstrap'
        empty_directory 'migrations' 

        ['test', 'development', 'production'].each do |env|
          template 'templates/environment.tt', "environments/#{env}.yaml", {:env=>env, :app_name=>app_name}
        end

        create_file File.join('bootstrap', '01_bootstrap.sql')
      end

      desc 'env', "Lists the available environments"
      def env()
        raise Error, "Currently not in the root of a db-cm created project.  Please go there and try again." unless valid_db_cm_project?
        config_dir = env_dir
        dir_entries = Dir.entries(config_dir).select{|e| e=~%r[.*\.yaml]}
        envs = []
        dir_entries.each do |entry|
          env_config = YAML.load_file(File.join(config_dir, entry))
          envs << [env_config['env_name'], env_config['db']['connection_string']]
        end
          
        table = Terminal::Table.new :headings => ['Environments', 'Connection String'], :rows => envs

        say table.to_s

        envs.map{|e|e[0]}
      end
      
      desc 'add "COMMENT"', "Adds a new migration and associates the comment with it"
      def add(comment)
        raise Error, "Currently not in the root of a db-cm created project.  Please go there and try again." unless valid_db_cm_project?
        
        time_now = Time.now
        migration_dir = time_now.strftime('%Y%m%d_%H%M%S')
        migration_base_dir = File.join('migrations', migration_dir)
        empty_directory migration_base_dir

        create_file File.join(migration_base_dir, '10_ddl.sql')
        create_file File.join(migration_base_dir, '20_data.sql')
        create_file File.join(migration_base_dir, '30_constraints.sql')
        create_file File.join(migration_base_dir, '40_indexes.sql')
        create_file File.join(migration_base_dir, '50_sequences.sql')
        create_file File.join(migration_base_dir, '60_triggers.sql')
        create_file File.join(migration_base_dir, '70_sprocs.sql')
        create_file File.join(migration_base_dir, '80_custom.sql')
        create_file File.join(migration_base_dir, '90_grants.sql')
        create_file File.join(migration_base_dir, 'version.txt'), comment

        undo_base_dir = File.join(migration_base_dir, 'undo')
        empty_directory undo_base_dir
        create_file File.join(undo_base_dir, '10_ddl.sql')
        create_file File.join(undo_base_dir, '20_data.sql')
        create_file File.join(undo_base_dir, '30_constraints.sql')
        create_file File.join(undo_base_dir, '40_indexes.sql')
        create_file File.join(undo_base_dir, '50_sequences.sql')
        create_file File.join(undo_base_dir, '60_triggers.sql')
        create_file File.join(undo_base_dir, '70_sprocs.sql')
        create_file File.join(undo_base_dir, '80_custom.sql')
        create_file File.join(undo_base_dir, '90_grants.sql')
      end

      desc 'bootstrap ENV_NAME', 'runs the bootstrap scripts for the specified environment'
      def bootstrap(env_name)
        unless has_bootstrap_available?
          say "No bootstrap to run"
          return false
        end
        
        load_environment env_name
#        check_db_settings



        
        
      end
      
      

      private
      def valid_db_cm_project?()
        File.directory?(File.join(self.destination_root, 'migrations'))
      end

      def load_environment(name)
        env_file = File.join(env_dir, "#{name}.yaml")
        raise Error, "Could not find matching environment file '#{name}.yaml' in #{env_dir}" if not File.exists?(env_file)
        @config = YAML.load_file env_file        
      end

      def check_db_settings()
        raise Error, "No environment configuration specified"

        env_name = ['env_name']
        @username = @config['db']['username']
        if @username.nil?
          @username = ask "Please enter a username for #{env_name}"
        end
        @password = @config['db']['password']
        if @password.nil?
          @password = ask "Please enter a password for #{env_name}"
        end
      end
      
      def env_dir()
        File.join(self.destination_root, 'environments')
      end
      
      def bootstrap_dir()
        File.join(self.destination_root, 'bootstrap')
      end

      def has_bootstrap_available?()
        sql_entries = Dir.entries(bootstrap_dir).select{|e| e=~%r[.*\.sql]}
        sql_entries.each do |sql|
          unless File.stat(File.join(bootstrap_dir, sql)).zero?
            return true
          end          
        end
        
        return false
      end
      
      
    end
  end
end
