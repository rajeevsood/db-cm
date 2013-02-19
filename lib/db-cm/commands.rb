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
        empty_directory File.join('migrations', 'versionlog')

        ['test', 'development', 'production'].each do |env|
          template 'templates/environment.tt', "environments/#{env}.yaml", {:env=>env, :app_name=>app_name}
        end

        create_file File.join('bootstrap', 'custom_01.sql')



        
      end



      

      
    end
  end
end
