require 'java'

java_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'ext'))
$LOAD_PATH << java_dir

require 'asm-3.3.1.jar'
require 'cglib-2.2.2.jar'
require "commons-logging-1.1.1.jar"
require 'derby.jar'
require 'javassist-3.17.1-GA.jar'
require "log4j-1.2.17.jar"
require 'mybatis-3.2.0.jar'
require "slf4j-api-1.7.2.jar"
require "slf4j-log4j12-1.7.2.jar"

=begin
java_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'ext'))
puts "Java dir:  '#{java_dir}'"
puts Dir.entries(java_dir)
Dir.entries(java_dir).each do |jar_file|
  jar_path = File.join(java_dir, jar_file)
  puts jar_path
  if jar_file=~%r[.*\.jar]
    require jar_path
  end
end
=end
java_import java.sql.DriverManager
java_import java.io.StringReader
java_import java.io.StringWriter
java_import java.io.PrintWriter
java_import org.apache.ibatis.jdbc.SqlRunner
java_import org.apache.ibatis.jdbc.ScriptRunner

module Db
  module Cm
    module Db
      class ConnectionAdapter
        DEFAULT_DELIMITER = ';'
        MULTILINE_DELIMITER = '/'

        def initialize(connection_string, driver, username, password, default_delimiter=DEFAULT_DELIMITER, multiline_delimiter=MULTILINE_DELIMITER)
          @connection_string = connection_string
          @driver_name = driver
          @username = username
          @password = password
          unless default_delimiter.nil?
            @default_delimiter = default_delimiter
          else
            @default_delimiter = DEFAULT_DELIMITER
          end

          unless multiline_delimiter.nil?
            @multiline_delimiter = multiline_delimiter
          else
            @multiline_delimiter = MULTILINE_DELIMITER
          end
          @multiline_delimiter_regex = Regexp.new(Regexp.escape(@multiline_delimiter))

          java_import @driver_name
          @driver_class = JavaUtilities.get_proxy_class @driver_name
#          java_import @driver_name
#          @driver_class = eval("java_import @driver_name")
#          puts "name:#{@driver_name} class:#{@driver_class}"
          @driver = @driver_class.new
          Java::JavaSql::DriverManager.registerDriver @driver
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
          script_runner = get_script_runner

          script_results = Java::JavaIo::StringWriter.new
          results_channel = Java::JavaIo::PrintWriter.new script_results
          script_runner.log_writer = results_channel
          script_runner.error_log_writer = results_channel


          #split out the create triggers, sprocs, functions, and packages from the single line scripts
          script_segments = []
          current_segment = nil
          script.each_line do |line|
            if /CREATE (?:OR REPLACE) (?:TRIGGER|PROCEDURE|FUNCTION|PACKAGE)/i =~ line
              script_segments << current_segment unless current_segment.nil?

              current_segment = ::Db::Cm::Db::ScriptSegment.new(line, @multiline_delimiter)
            elsif @multiline_delimiter_regex =~ line
              unless current_segment.nil?
                current_segment << line
                script_segments << current_segment
              end
              current_segment = nil
            else
              if current_segment.nil?
                current_segment = ::Db::Cm::Db::ScriptSegment.new(line, @default_delimiter)
              else
                current_segment << line
              end
            end
          end

          script_segments << current_segment unless current_segment.nil?

          script_segments.each do |script_segment|
            reader = Java::JavaIo::StringReader.new script_segment.segment
            script_runner.delimiter = script_segment.delimiter
            script_runner.run_script reader
          end

          script_runner.delimiter=@default_delimiter

          script_results.to_string
        end

        def insert(sql, *args)
          sql_runner = get_sql_runner
          unless args.empty?
            number_records_updated = sql_runner.insert sql, args.to_java
          else
            number_records_updated = sql_runner.insert sql
          end

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

        def table_exists?(schema_name, table_name)
          connect
          meta_data = @connection.get_meta_data
          tables = meta_data.get_tables(nil, schema_name.upcase, table_name.upcase, nil)
          result = (not tables.nil? and tables.next)
          tables.close
          result
        end

        private
        def get_sql_runner
          connect
          @connection.auto_commit = true
          sql_runner = Java::OrgApacheIbatisJdbc::SqlRunner.new @connection
          sql_runner.use_generated_key_support = false
          sql_runner
        end

        def get_script_runner
          connect
          @connection.auto_commit = true
          script_runner = Java::OrgApacheIbatisJdbc::ScriptRunner.new @connection
          script_runner.setStopOnError true
          script_runner.setEscapeProcessing false
          script_runner.setAutoCommit true
#          script_runner.setSendFullScript true
#          scriptRunner.setAutoCommit(Boolean.valueOf(props.getProperty("auto_commit")));
#          scriptRunner.setDelimiter(delimiterString == null ? ";" : delimiterString);
#          scriptRunner.setFullLineDelimiter(Boolean.valueOf(props.getProperty("full_line_delimiter")));
#          scriptRunner.setSendFullScript(Boolean.valueOf(props.getProperty("send_full_script")));
#          scriptRunner.setRemoveCRs(Boolean.valueOf(props.getProperty("remove_crs")));
          script_runner
        end

        def connect
          if @connection.nil? or not @connection.is_valid? 0
            unless (@username.nil? or @password.nil?)
              @connection = Java::JavaSql::DriverManager.getConnection(@connection_string, @username, @password)
            else
              @connection = Java::JavaSql::DriverManager.getConnection(@connection_string)
            end
          end
          @connection
        end
      end
    end    
  end
end
