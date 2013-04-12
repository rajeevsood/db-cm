require 'db-cm/version_log'
require 'db-cm/version_log_entry'
#include_class 'org.apache.derby.jdbc.EmbeddedDriver'

describe Db::Cm::VersionLog do

  before :each do
    time = Time.new.usec
#    Java::OrgApacheDerbyJdbc::EmbeddedDriver.new
    @connection_string = "jdbc:derby:memory:derbyDB_#{time};create=true"
    @driver = 'org.apache.derby.jdbc.EmbeddedDriver'
    @sut = Db::Cm::VersionLog.new get_connection_adapter, "SCHEMA_NAME", "TABLE_NAME"
  end
  
  describe "#version_log_table_exists?" do
    it "returns false when the table does not exist" do
      does_table_exist = @sut.version_log_table_exists?
      does_table_exist.should be_false
    end 
  end

  describe "#create_table" do
    it "returns true when the table is created" do
      result = @sut.create_table

      @sut.version_log_table_exists?.should be_true
    end
  end

  describe "#insert_entry" do
    it "returns true when the new entry is inserted" do
      result = @sut.create_table

      does_table_exist = @sut.version_log_table_exists?
      does_table_exist.should be_true

      migration_id = "Foobar"
      comment = "blah blah blah"
      result = @sut.insert_entry(migration_id, comment)
      result.should be_true
    end
  end

  describe "#drop_table" do
    it "returns false when querying if the table exists after the table is dropped" do
      result = @sut.create_table
 
      does_table_exist = @sut.version_log_table_exists?
      does_table_exist.should be_true

      result = @sut.drop_table

      does_table_exist = @sut.version_log_table_exists?
      does_table_exist.should be_false
    end
  end

  describe "#get_entries" do
    it "returns true when the new entry is inserted" do
      result = @sut.create_table

      does_table_exist = @sut.version_log_table_exists?
      does_table_exist.should be_true

      migration_id = "Foobar"
      comment = "blah blah blah"
      result = @sut.insert_entry(migration_id, comment)
      result.should be_true
      entries = @sut.get_entries
      entries.count.should be 1
      entries.first.migration_id.should eq migration_id
      entries.first.description.should eq comment
    end
  end




  private
#  def get_connection
#    Java::JavaSql::DriverManager.getConnection @connection_string
#  end
  def get_connection_adapter
    Db::Cm::Db::ConnectionAdapter.new @connection_string, @driver, '', ''
  end
end
