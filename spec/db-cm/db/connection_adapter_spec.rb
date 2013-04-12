require 'db-cm/db/connection_adapter'
require 'db-cm/db/script_segment'
#include_class 'org.apache.derby.jdbc.EmbeddedDriver'

describe Db::Cm::Db::ConnectionAdapter do
  before :each do
    time = Time.new.usec
    @connection_string = "jdbc:derby:memory:derbyDB_#{time};create=true"
    @driver = 'org.apache.derby.jdbc.EmbeddedDriver'
#    Java::OrgApacheDerbyJdbc::EmbeddedDriver.new
    @sut = Db::Cm::Db::ConnectionAdapter.new @connection_string, @driver, '', ''
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

  describe "#do_script" do
    it "successfully runs script when no multiline commands present" do
      script = "SELECT * FROM SYS.SYSUSERS;"

      script_runner = double("Java::OrgApacheIbatisJdbc::ScriptRunner")
      script_runner.stub(:setStopOnError)
      script_runner.stub(:setEscapeProcessing)
      script_runner.stub(:setAutoCommit)
      script_runner.stub(:log_writer=)
      script_runner.stub(:error_log_writer=)
      script_runner.stub(:run_script).and_return(script)

      results = @sut.do_script script
    end
    it "successfully runs script when only a multiline command is present" do
      script = <<EOL
CREATE OR REPLACE TRIGGER t1  before insert ON SYS.SYSUSERS for each row
declare
  foo number;
begin
  if :foo is null then
    select COUNT(*) into :foo FROM SYS.SYSUSERS;
  else
    select COUNT(*) into :foo FROM SYS.SYSUSERS;
  end if;
end;
/
EOL
      script_runner = double("Java::OrgApacheIbatisJdbc::ScriptRunner")
      script_runner.stub(:setStopOnError)
      script_runner.stub(:setEscapeProcessing)
      script_runner.stub(:setAutoCommit)
      script_runner.stub(:log_writer=)
      script_runner.stub(:error_log_writer=)
      script_runner.stub(:run_script).and_return(script)
      script_runner.should_receive(:delimiter=).with(';').once
      script_runner.should_receive(:delimiter=).with('/').once

      Java::OrgApacheIbatisJdbc::ScriptRunner.stub!(:new).and_return(script_runner)

      results = @sut.do_script script
    end
    it "successfully runs script when both a single line command and a multiline command is present" do
      script_1 = "SELECT * FROM SYS.SYSUSERS;"
      script_2 = <<EOL
CREATE OR REPLACE TRIGGER t1  before insert ON SYS.SYSUSERS for each row
declare
  foo number;
begin
  if :foo is null then
    select COUNT(*) into :foo FROM SYS.SYSUSERS;
  else
    select COUNT(*) into :foo FROM SYS.SYSUSERS;
  end if;
end;
/
EOL
      script_runner = double("Java::OrgApacheIbatisJdbc::ScriptRunner")
      script_runner.stub(:setStopOnError)
      script_runner.stub(:setEscapeProcessing)
      script_runner.stub(:setAutoCommit)
      script_runner.stub(:log_writer=)
      script_runner.stub(:error_log_writer=)
      script_runner.should_receive(:delimiter=).with(';').twice
      script_runner.should_receive(:delimiter=).with('/').once
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_1}.and_return(script_1)
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_2}.and_return(script_2)

      Java::OrgApacheIbatisJdbc::ScriptRunner.stub!(:new).and_return(script_runner)

      script = "#{script_1}\n#{script_2}"

      results = @sut.do_script script
    end

    it "successfully runs script when a complex script with both single line commands and multiline commands are present" do
      script_1 = "SELECT * FROM SYS.SYSUSERS;"
      script_2 = <<EOL
CREATE OR REPLACE TRIGGER t1  before insert ON SYS.SYSUSERS for each row
declare
  foo number;
begin
  if :foo is null then
    select COUNT(*) into :foo FROM SYS.SYSUSERS;
  else
    select COUNT(*) into :foo FROM SYS.SYSUSERS;
  end if;
end;
/
EOL
      script_3 = "#{script_1}\n#{script_1}\n#{script_1}"
      script_4 = script_2
      script_5 = "#{script_1}\n#{script_1}\n#{script_1}\n#{script_1}\n#{script_1}"


      script_runner = double("Java::OrgApacheIbatisJdbc::ScriptRunner")
      script_runner.stub(:setStopOnError)
      script_runner.stub(:setEscapeProcessing)
      script_runner.stub(:setAutoCommit)
      script_runner.stub(:log_writer=)
      script_runner.stub(:error_log_writer=)
      script_runner.should_receive(:delimiter=).with(';').exactly(4).times
      script_runner.should_receive(:delimiter=).with('/').twice
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_1}.and_return(script_1)
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_2}.and_return(script_2)
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_3}.and_return(script_3)
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_4}.and_return(script_4)
      script_runner.should_receive(:run_script).with(any_args){|arg| contents(arg).should == script_5}.and_return(script_5)

      Java::OrgApacheIbatisJdbc::ScriptRunner.stub!(:new).and_return(script_runner)

      script = "#{script_1}\n#{script_2}\n#{script_3}\n#{script_4}\n#{script_5}"

      results = @sut.do_script script
    end

    def contents(reader)
      result = ''
      c = reader.read
      while(c != -1)
        result << c
        c = reader.read
      end

      reader.reset
    end
  end
end
