require 'db-cm/version_log'
include_class 'org.apache.derby.jdbc.EmbeddedDriver'

describe Db::Cm::VersionLog do
    # require 'ruby-debug';debugger;

  before :each do
    time = Time.new.usec
    Java::OrgApacheDerbyJdbc::EmbeddedDriver.new
    @connection_string = "jdbc:derby:memory:derbyDB_#{time};create=true" 
    @sut = Db::Cm::VersionLog.new "SCHEMA_NAME", "TABLE_NAME"
  end
  
  describe "#does_version_log_table_exist?" do
    it "returns false when the table does not exist" do
      does_table_exist = @sut.does_version_log_table_exist?(get_connection)
      does_table_exist.should be_false
    end 
  end

  describe "#create_table" do
    it "returns true when the table is created" do
      result = @sut.create_table(get_connection_adapter)

      does_table_exist = @sut.does_version_log_table_exist?(get_connection)
      does_table_exist.should be_true
    end
  end

  describe "#insert_entry" do
    it "returns true when the new entry is inserted" do
      result = @sut.create_table(get_connection_adapter)

      does_table_exist = @sut.does_version_log_table_exist?(get_connection)
      does_table_exist.should be_true

      migration_id = "Foobar"
      comment = "blah blah blah"
      result = @sut.insert_entry(get_connection_adapter, migration_id, comment)
      result.should be_true
    end
  end

  describe "#drop_table" do
    it "returns false when querying if the table exists after the table is dropped" do
      result = @sut.create_table(get_connection_adapter)
 
      does_table_exist = @sut.does_version_log_table_exist?(get_connection)
      does_table_exist.should be_true

      result = @sut.drop_table(get_connection_adapter)

      does_table_exist = @sut.does_version_log_table_exist?(get_connection)
      does_table_exist.should be_false
    end
  end



  private
  def get_connection    
    Java::JavaSql::DriverManager.getConnection @connection_string
  end
  def get_connection_adapter
    Db::Cm::Db::ConnectionAdapter.new @connection_string, '', ''
  end


end
