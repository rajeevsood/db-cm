require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"
require "terminal-table"
require "yaml"
require "highline/import"

module Db
  module Cm
    class Commands < Thor
      include Thor::Actions
      package_name 'db-cm'

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
        create_file File.join('bootstrap', 'comment.txt'), 'Initial bootstrap'
      end

      desc 'env', "Lists the available environments"
      def env()
        raise Error, "Currently not in the root of a db-cm created project.  Please go there and try again." unless valid_db_cm_project?
        config_dir = env_dir
        dir_entries = Dir.entries(config_dir).select{|e| e=~%r[.*\.yaml]}
        envs = []
        dir_entries.each do |entry|
#          env_config = YAML.load_file(File.join(config_dir, entry))
          env_config = File.open(File.join(config_dir, entry), 'r') {|f| YAML.load(f)}
          envs << [env_config['env_name'], env_config['db']['driver'], env_config['db']['connection_string']]
        end
          
        table = Terminal::Table.new :headings => ['Environments', 'Driver', 'Connection String'], :rows => envs

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
        create_file File.join(migration_base_dir, 'comment.txt'), comment

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
        check_db_settings

        connection_adapter = get_connection_adapter
        migration_directory = bootstrap_dir
        scripts = scripts_for_migration migration_directory
        comment = comment_for_migration migration_directory

        results = run_migration connection_adapter, migration_directory, VersionLog::BOOTSTRAP_MIGRATION_ID, scripts, comment
      end

      desc 'status ENV_NAME', 'report the current status of the database for the specified environment'
      def status(env_name)
=begin
        load_environment env_name
        check_db_settings

        entries = []
        #calculate local
        entries = migrations_from_local_repository

        connection_adapter = get_connection_adapter
        version_log = VersionLog.new connection_adapter, @config['schema_name'], @config['version_log_table_name']
        if version_log.version_log_table_exists?
          db_entries = version_log.get_entries

          db_entries.each do |db_entry|
            the_index = entries.index{|e| e.migration_id==db_entry.migration_id}
            next if the_index.nil?
            entries[the_index] = db_entry
          end
        end
=end
        entries = calculate_status env_name
        table_entries = entries.map {|entry| [entry.migration_id, entry.applied_at, entry.description]}

        table = Terminal::Table.new :headings => ['Id', 'Applied At', 'Description'], :rows => table_entries

        say table.to_s
        entries
      end

      desc 'up ENV_NAME [NUM_MIGRATIONS_TO_RUN]', 'runs all of the migrations newer than the current state against the database for the specified environment.  Use second parameter to limit the number of migrations to apply.'
      def up(env_name, steps_to_run=-1)
        load_environment env_name
        check_db_settings

        connection_adapter = get_connection_adapter

        #calculate and run the pending migrations
        entries = calculate_status env_name
        entries.reverse!

        new_migrations = []
        entries.each do |entry|
          unless entry.already_run?
            new_migrations << entry
          else
            break
          end
        end

        new_migrations.reverse!

        while ((not new_migrations.empty?) and steps_to_run != 0)
          entry = new_migrations.shift

          migration_directory = migration_dir entry.migration_id
          scripts = scripts_for_migration migration_directory
          comment = comment_for_migration migration_directory

          run_migration connection_adapter, migration_directory, entry.migration_id, scripts, comment

          steps_to_run = steps_to_run - 1
        end
      end


      private
      def calculate_status(env_name)
        load_environment env_name
        check_db_settings

        entries = []
        #calculate local
        entries = migrations_from_local_repository

        connection_adapter = get_connection_adapter
        version_log = VersionLog.new connection_adapter, @config['schema_name'], @config['version_log_table_name']
        if version_log.version_log_table_exists?
          db_entries = version_log.get_entries

          db_entries.each do |db_entry|
            the_index = entries.index{|e| e.migration_id==db_entry.migration_id}
            next if the_index.nil?
            entries[the_index] = db_entry
          end
        end

        entries
      end

      def run_migration(connection_adapter, migration_directory, migration_id, scripts, comment)
        results = ''
        version_log = VersionLog.new connection_adapter, @config['schema_name'], @config['version_log_table_name']

        unless version_log.version_log_table_exists?
          version_log.create_table
          raise Error, 'problem creating version log table' unless version_log.version_log_table_exists?
        end

        substitutions = {'schema_name'=>@config['schema_name']}
        substitutions.merge! @config['variables'] unless @config['variables'].nil?

        #make the keys symbols for the % format below
        substitutions = Hash[substitutions.map{|(k,v)| [k.to_sym,v]}]

        scripts.each do |script|
          script_contents = File.open(File.join(migration_directory, script), 'rb') {|f| f.read }
          script_contents = script_contents % substitutions

#          puts "script[#{script}]:  '#{script_contents}'"

          results = connection_adapter.do_script script_contents
        end

        #add comment for migration
        success = version_log.insert_entry migration_id, comment

        results << "\r\n Version Log table update failed for migration #{migration_id}" unless success

        results
      end

      def valid_db_cm_project?()
        File.directory?(File.join(self.destination_root, 'migrations'))
      end

      def load_environment(name)
        env_file = File.join(env_dir, "#{name}.yaml")
        raise Error, "Could not find matching environment file '#{name}.yaml' in #{env_dir}" if not File.exists?(env_file)
        @config = File.open(env_file, 'r') {|f| YAML.load(f)}
      end

      def check_db_settings()
        env_name = @config['env_name']

        @driver = @config['db']['driver']
        raise Error, "No driver specified for environment '#{env_name}'" if @driver.nil?

        @username = @config['db']['username'] if not defined?(@username) or @username.nil?
        if @username.nil?
          @username = ask "Please enter a username for #{env_name}:\t"
        end
        @password = @config['db']['password'] if not defined?(@password) or @password.nil?
        if @password.nil?
          @password = HighLine.new.ask("Please enter a password for #{env_name}:\t") {|q| q.echo = false}
        end
      end
      
      def env_dir()
        File.join(self.destination_root, 'environments')
      end
      
      def bootstrap_dir()
        File.join(self.destination_root, 'bootstrap')
      end

      def migration_dir(migration_id)
        File.join(migration_root_dir, migration_id)
      end

      def migration_root_dir
        File.join(self.destination_root, 'migrations')
      end

      def migration_comment_filename(migration_dir)
        File.join(migration_dir, 'comment.txt')
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

      def migrations_from_local_repository()
        raise Error, "Currently not in the root of a db-cm created project.  Please go there and try again." unless valid_db_cm_project?

        repository_entries = []

        if has_bootstrap_available?
          comment = comment_for_migration bootstrap_dir
          repository_entries << VersionLogEntry.new(VersionLog::BOOTSTRAP_MIGRATION_ID, VersionLog::PENDING_APPLIED_AT, comment, false)
        end

        migrations = Dir.entries(migration_root_dir).select{|e| (File.directory?(File.join(migration_root_dir, e)) and e=~%r[\d\w*])}.sort

        migrations.each do |migration_id|
          comment = comment_for_migration migration_dir migration_id
          repository_entries << VersionLogEntry.new(migration_id, VersionLog::PENDING_APPLIED_AT, comment, false)
        end

        repository_entries
      end
      
      def scripts_for_migration_id(migration_id)
        raise Error, 'no migration specified' if migration_id.nil?
        migration_dir = migration_dir(migration_id)
        scripts_for_migration migration_dir
      end

      def scripts_for_migration(migration_dir)
        raise Error, "Directory '#{migration_dir}' does not exist or is not a directory" unless Dir.exists?(migration_dir)

        scripts = []
        sql_entries = Dir.entries(migration_dir).select{|e| e=~%r[.*\.sql]}
        sql_entries.each do |sql|
          unless File.stat(File.join(migration_dir, sql)).zero?
            scripts << sql
          end
        end
      
        scripts.sort!
      end

      def comment_for_migration_id(migration_id)
        raise Error, 'no migration specified' if migration_id.nil?
        migration_dir = migration_dir(migration_id)
        comment_for_migration migration_dir
      end

      def comment_for_migration(migration_dir)
        raise Error, "Directory '#{migration_dir}' does not exist or is not a directory" unless Dir.exists?(migration_dir)
        comment_filename = migration_comment_filename(migration_dir)
        raise Error, "Comment file '#{comment_filename}' does not exist" unless File.exist?(comment_filename)
        raise Error, "Comment file '#{comment_filename}' is empty.  Please supply a comment." if File.stat(comment_filename).zero?

        File.open(comment_filename, 'rb') {|f| f.read }
      end

      def get_connection_adapter
        Db::ConnectionAdapter.new(@config['db']['connection_string'], @config['db']['driver'], @username,
                                  @password, @config['default_delimiter'], @config['multiline_delimiter'])
      end
    end
  end
end
