require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"

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

        create_file File.join('bootstrap', '80_custom.sql')
      end

      
      desc 'add "COMMENT"', "Adds a new migration and associates the comment with it"
      def add(comment)
        raise Error, "Currently not in the root of a db-cm created project.  Please go there and try again." if File.directory?('migrations')
        
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

      
    end
  end
end
