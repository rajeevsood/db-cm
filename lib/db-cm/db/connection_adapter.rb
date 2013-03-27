require 'java'

java_dir = File.join(File.dirname(__FILE__), '..', '..', '..', 'ext')
Dir.entries(java_dir).each do |jar_file|
  require File.join(java_dir, jar_file) if jar_file=~%r[.*\.jar]
end
include_class 'java.sql.DriverManager'
include_class 'java.io.StringReader'
include_class 'java.io.StringWriter'
include_class 'java.io.PrintWriter'
include_class 'org.apache.ibatis.jdbc.SqlRunner'
include_class 'org.apache.ibatis.jdbc.ScriptRunner'

module Db
  module Cm
    module Db
      class ConnectionAdapter
        def initialize(connection_string, username, password)
          @connection_string = connection_string
          @username = username
          @password = password
        end
        
        def select(sql)
          sql_runner = get_sql_runner
          records = sql_runner.select_all sql
          results = []
          records.each do |record|
            results << record
          end
          results
        end
        
        def do_script(script)
          reader = Java::JavaIo::StringReader.new script
          script_runner = get_script_runner

          script_results = Java::JavaIo::StringWriter.new
          results_channel = Java::JavaIo::PrintWriter.new script_results
          script_runner.log_writer = results_channel
          script_runner.error_log_writer = results_channel

          script_runner.run_script reader

          script_results.to_string
        end

        def insert(sql)
          sql_runner = get_sql_runner
          number_records_updated = sql_runner.insert sql
          number_records_updated
        end

        def delete(sql)
          sql_runner = get_sql_runner
          number_records_updated = sql_runner.delete sql
          number_records_updated
        end

        def update(sql)
          sql_runner = get_sql_runner
          number_records_updated = sql_runner.update sql
          number_records_updated
        end

        private
        def get_sql_runner
          connection = connect
          connection.auto_commit = true
          sql_runner = Java::OrgApacheIbatisJdbc::SqlRunner.new connection
          sql_runner.use_generated_key_support = false
          sql_runner
        end

        def get_script_runner
          connection = connect
          connection.auto_commit = true
          script_runner = Java::OrgApacheIbatisJdbc::ScriptRunner.new connection
          script_runner.setStopOnError true
          script_runner.setEscapeProcessing false
#          scriptRunner.setAutoCommit(Boolean.valueOf(props.getProperty("auto_commit")));
#          scriptRunner.setDelimiter(delimiterString == null ? ";" : delimiterString);
#          scriptRunner.setFullLineDelimiter(Boolean.valueOf(props.getProperty("full_line_delimiter")));
#          scriptRunner.setSendFullScript(Boolean.valueOf(props.getProperty("send_full_script")));
#          scriptRunner.setRemoveCRs(Boolean.valueOf(props.getProperty("remove_crs")));
          script_runner
        end

        def connect
          unless (@username.nil? or @password.nil?)
            @connection = Java::JavaSql::DriverManager.getConnection(@connection_string, @username, @password)
          else
            @connection = Java::JavaSql::DriverManager.getConnection(@connection_string)
          end
        end
      end
    end    
  end
end
