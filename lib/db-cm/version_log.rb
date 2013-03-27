module Db
  module Cm
    class VersionLog

  CREATE_VERSION_LOG_STATEMENT = <<EOS
      CREATE TABLE %{schema_table} (
        MIGRATION_ID VARCHAR(50) NOT NULL,
        APPLIED_AT VARCHAR(25) NOT NULL,
        DESCRIPTION VARCHAR(255) NOT NULL
      );

      ALTER TABLE %{schema_table}
        ADD CONSTRAINT PK_%{table}
        PRIMARY KEY (MIGRATION_ID);
EOS
      DROP_VERSION_LOG_TABLE = "DROP TABLE %{schema_table};"
      #
      INSERT_VERSION_LOG_TABLE = "INSERT INTO %{schema_table}(MIGRATION_ID, APPLIED_AT, DESCRIPTION)
                                  VALUES('%{migration_id}', '%{apply_date_time}', '%{description}')"

      def initialize(schema_name=nil, table_name)
        @schema_name = schema_name
        @table_name = table_name
        unless @schema_name.nil? or @schema_name.empty?
          @schema_table_value = "#{@schema_name}.#{@table_name}"
        else
          @schema_table_value = @table_name
        end
      end

      def does_version_log_table_exist?(connection)
        meta_data = connection.get_meta_data
        tables = meta_data.get_tables(nil, @schema_name, @table_name, nil)
        result = (not tables.nil? and tables.next)
        tables.close
        result
      end

      def create_table(connection_adapter)
        script = CREATE_VERSION_LOG_STATEMENT % {:schema_table=>@schema_table_value, :table=>@table_name}
        connection_adapter.do_script script
      end

      def drop_table(connection_adapter)
        script = DROP_VERSION_LOG_TABLE % {:schema_table=>@schema_table_value}
        connection_adapter.do_script script
      end

      def insert_entry(connection_adapter, migration_id, comment)
        apply_date_time = DateTime.now.strftime('%Y%m%d_%H%M%S')

        values = {:schema_table=>@schema_table_value, :table=>@table_name,
                  :migration_id=>migration_id, :apply_date_time=>apply_date_time, :description=>comment}
        script = INSERT_VERSION_LOG_TABLE % values
        connection_adapter.insert script
        return true
      end
    end
  end
end
