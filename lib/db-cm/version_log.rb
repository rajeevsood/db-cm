module Db
  module Cm
    class VersionLog

  CREATE_VERSION_LOG_STATEMENT = <<EOS
      CREATE TABLE %{schema_table} (
        MIGRATION_ID VARCHAR(50) NOT NULL,
        APPLIED_AT VARCHAR(45) NOT NULL,
        DESCRIPTION VARCHAR(512) NOT NULL
      );

      ALTER TABLE %{schema_table}
        ADD CONSTRAINT PK_%{table}
        PRIMARY KEY (MIGRATION_ID);
EOS
      DROP_VERSION_LOG_TABLE = "DROP TABLE %{schema_table};"

      INSERT_VERSION_LOG_TABLE = "INSERT INTO %{schema_table}(MIGRATION_ID, APPLIED_AT, DESCRIPTION)
                                  VALUES(?,?,?)"
      SELECT_ALL_VERSION_LOG_TABLE = "SELECT * FROM %{schema_table} ORDER BY MIGRATION_ID ASC"

      BOOTSTRAP_MIGRATION_ID = '0000'

      PENDING_APPLIED_AT = '...Pending...'

      def initialize(connection_adapter, schema_name=nil, table_name)
        @connection_adapter = connection_adapter
        @schema_name = schema_name
        @table_name = table_name
        unless @schema_name.nil? or @schema_name.empty?
          @schema_table_value = "#{@schema_name}.#{@table_name}"
        else
          @schema_table_value = @table_name
        end
      end

      def version_log_table_exists?
        @connection_adapter.table_exists? @schema_name, @table_name
      end

      def create_table
        script = CREATE_VERSION_LOG_STATEMENT % {:schema_table=>@schema_table_value, :table=>@table_name}
        @connection_adapter.do_script script
      end

      def drop_table
        script = DROP_VERSION_LOG_TABLE % {:schema_table=>@schema_table_value}
        @connection_adapter.do_script script
      end

      def get_entries
        values = {:schema_table=>@schema_table_value}
        script = SELECT_ALL_VERSION_LOG_TABLE % values
        result = @connection_adapter.select script
        entries = []
        result.each do |entry|
          entries << VersionLogEntry.new(entry['MIGRATION_ID'], entry['APPLIED_AT'], entry['DESCRIPTION'], true)
        end
        entries
      end

      def insert_entry(migration_id, comment)
        apply_date_time = Time.new.strftime('%Y/%m/%d %H:%M:%S.%L')

        values = {:schema_table=>@schema_table_value}
        script = INSERT_VERSION_LOG_TABLE % values
        @connection_adapter.insert script, migration_id, apply_date_time, comment
        return true
      end
    end
  end
end
