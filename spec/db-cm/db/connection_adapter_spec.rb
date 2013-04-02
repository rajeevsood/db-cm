require 'db-cm/db/connection_adapter'
include_class 'org.apache.derby.jdbc.EmbeddedDriver'

describe Db::Cm::Db::ConnectionAdapter do
    # require 'ruby-debug';debugger;

  before :each do
    time = Time.new.usec
    @connection_string = "jdbc:derby:memory:derbyDB_#{time};create=true"
    Java::OrgApacheDerbyJdbc::EmbeddedDriver.new
    @sut = Db::Cm::Db::ConnectionAdapter.new @connection_string, '', ''
  end
  
  describe "#select" do
    it "selects records from the database" do
      records = @sut.select "SELECT * FROM SYS.SYSUSERS" 
      records.should be_an_instance_of Array
    end
  end

  describe "#table_exists?" do
    it "returns true when the table exists in the database" do
      @sut.table_exists?('SYS', 'SYSUSERS').should be_true

    end
    it "returns false when the table does not exist in the database" do
      @sut.table_exists?('SYS', 'QWERTY').should be_false
    end
  end
end
