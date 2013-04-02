require 'db-cm/commands'

describe Db::Cm::Commands do
  before :each do
    @test_dir="test_root"
    @sut = Db::Cm::Commands.new
    @test_root_dir = @sut.destination_root

    FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    time = Time.new.to_i
    Java::OrgApacheDerbyJdbc::EmbeddedDriver.new
    @connection_string = "jdbc:derby:memory:derbyDB_#{time};create=true"
    @drop_connection_string = "jdbc:derby:memory:derbyDB_#{time};drop=true"
  end

  describe "#init" do
    before :each do      
      @sut.init @test_dir
    end

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    end
    
    it "creates the project root directory" do
      File.directory?(File.join(@test_root_dir, @test_dir)).should be_true
    end

    it "creates the @test_dir/environments sub-directory" do
      File.directory?(File.join(@test_root_dir, @test_dir, 'environments')).should be_true
    end

    it "creates the @test_dir/bootstrap sub-directory" do
      File.directory?(File.join(@test_root_dir, @test_dir, 'bootstrap')).should be_true
    end

    it "creates the @test_dir/bootstrap comment.txt file" do
      File.exists?(File.join(@test_root_dir, @test_dir, 'bootstrap', 'comment.txt')).should be_true
    end

    it "creates the @test_dir/migrations sub-directory" do
      File.directory?(File.join(@test_root_dir, @test_dir, 'migrations')).should be_true
    end

    it "creates the @test_dir/environments/test.yaml file" do
      File.exists?(File.join(@test_root_dir, @test_dir, 'environments', 'test.yaml')).should be_true
    end    

    it "creates the @test_dir/environments/development.yaml file" do
      File.exists?(File.join(@test_root_dir, @test_dir, 'environments', 'development.yaml')).should be_true
    end

    it "creates the @test_dir/environments/production.yaml file" do
      File.exists?(File.join(@test_root_dir, @test_dir, 'environments', 'production.yaml')).should be_true
    end

    it "creates the @test_dir/migrations/bootstrap/01_bootstrap.sql" do
      File.exists?(File.join(@test_root_dir, @test_dir, 'bootstrap', '01_bootstrap.sql')).should be_true
    end
  end

  describe "#add" do
    before :each do      
      @sut.init @test_dir

      @comment = 'new version comment'
      time_now = Time.now
      @dir_name = time_now.strftime('%Y%m%d_%H%M%S')

      Time.stub!(:now).and_return(time_now)
      
      @sut.add @comment
    end

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    end
    
    it "creates the migration root directory based on today's date" do      
      File.directory?(File.join(@test_root_dir, @test_dir, 'migrations', @dir_name)).should be_true
    end
    
    it "creates the comment.txt based on the comment" do
      comment_filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'comment.txt')
      File.exists?(comment_filename).should be_true
      comment_contents = IO.read(comment_filename)
      @comment.should eq comment_contents
    end

    it "creates the 10_ddl.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '10_ddl.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 20_data.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '20_data.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 30_constraints.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '30_constraints.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 40_indexes.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '40_indexes.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 50_sequences.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '50_sequences.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 60_triggers.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '60_triggers.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 70_sprocs.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '70_sprocs.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 80_custom.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '80_custom.sql')
      File.exists?(filename).should be_true
    end

    it "creates the 90_grants.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, '90_grants.sql')
      File.exists?(filename).should be_true
    end
    
    it "creates the undo/10_ddl.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '10_ddl.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/20_data.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '20_data.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/30_constraints.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '30_constraints.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/40_indexes.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '40_indexes.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/50_sequences.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '50_sequences.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/60_triggers.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '60_triggers.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/70_sprocs.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '70_sprocs.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/80_custom.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '80_custom.sql')
      File.exists?(filename).should be_true
    end

    it "creates the undo/90_grants.sql file" do
      filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'undo', '90_grants.sql')
      File.exists?(filename).should be_true
    end
  end

  describe "#env" do
    before :each do      
      @sut.init @test_dir
    end

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    end

    it "lists all the configured environments" do
      envs = @sut.env
      envs.should include 'test'
      envs.should include 'development'
      envs.should include 'production'
    end
end     

  describe "#bootstrap" do
    before :each do      
      @sut.init @test_dir
    end

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    end

    it 'does not do anything if the bootstrap directory has no sql to run' do
      result = @sut.bootstrap 'test'
      result.should be_false
    end
    
    it 'creates the version table and inserts the bootstrap record when the table is not there' do
      configure_test_environment @connection_string
      create_bootstrap_migration
      result = @sut.bootstrap 'test'
      result.should be_true
    end
  end

  describe "#status" do
    before :each do
      @sut.init @test_dir
      configure_test_environment_with_variables @connection_string
      create_bootstrap_migration
      @migration_id_1 = create_sample_migration_1
      sleep(1)
      @migration_id_2 = create_sample_migration_2
    end 

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    end

    it 'lists only local migrations in the repository with an Applied At value of "...pending..." if the version log table does not exist' do
      entries = @sut.status 'test'
      entries.each do |entry|
        entry.already_run?.should be_false
        entry.applied_at.should be Db::Cm::VersionLog::PENDING_APPLIED_AT
      end
    end

    it 'lists both local migrations in the repository and applied scripts in the database if the version log table exists and has the migrations applied' do
      entries = @sut.status 'test'
      entries.each do |entry|
        entry.already_run?.should be_false
        entry.applied_at.should be Db::Cm::VersionLog::PENDING_APPLIED_AT
      end

      result = @sut.bootstrap 'test'
      entries = @sut.status 'test'
      entries.each do |entry|
        if entry.migration_id == Db::Cm::VersionLog::BOOTSTRAP_MIGRATION_ID
          entry.already_run?.should be_true
          entry.applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
        else
          entry.already_run?.should be_false
          entry.applied_at.should be Db::Cm::VersionLog::PENDING_APPLIED_AT
        end
      end

      result = @sut.up 'test'
      entries = @sut.status 'test'
      entries.each do |entry|
        entry.already_run?.should be_true
        entry.applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
      end
    end
  end

  describe "#up" do
    before :each do
      @sut.init @test_dir
      configure_test_environment_with_variables @connection_string
      create_bootstrap_migration
      @migration_id_1 = create_sample_migration_1
      sleep(1)
      @migration_id_2 = create_sample_migration_2
      result = @sut.bootstrap 'test'
    end

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir), true
    end

    it 'runs all migrations when up is called with no number of steps specified and updates the version log table appropriately' do
      entries = @sut.status 'test'
      entries.each do |entry|
        if entry.migration_id == Db::Cm::VersionLog::BOOTSTRAP_MIGRATION_ID
          entry.already_run?.should be_true
          entry.applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
        else
          entry.already_run?.should be_false
          entry.applied_at.should be Db::Cm::VersionLog::PENDING_APPLIED_AT
        end
      end

      result = @sut.up 'test'
      entries = @sut.status 'test'
      entries.each do |entry|
        entry.already_run?.should be_true
        entry.applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
      end
    end

    it 'runs migrations individually when up is called with 1 step is specified and updates the version log table appropriately' do
      entries = @sut.status 'test'
      entries.each do |entry|
        if entry.migration_id == Db::Cm::VersionLog::BOOTSTRAP_MIGRATION_ID
          entry.already_run?.should be_true
          entry.applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
        else
          entry.already_run?.should be_false
          entry.applied_at.should be Db::Cm::VersionLog::PENDING_APPLIED_AT
        end
      end

      result = @sut.up 'test', 1
      entries = @sut.status 'test'
      entries[0].migration_id.should be_eql Db::Cm::VersionLog::BOOTSTRAP_MIGRATION_ID
      entries[0].already_run?.should be_true
      entries[0].applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
      entries[1].already_run?.should be_true
      entries[1].applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
      entries[2].already_run?.should be_false
      entries[2].applied_at.should be Db::Cm::VersionLog::PENDING_APPLIED_AT

      result = @sut.up 'test', 1
      entries = @sut.status 'test'
      entries.each do |entry|
        entry.already_run?.should be_true
        entry.applied_at.should_not be Db::Cm::VersionLog::PENDING_APPLIED_AT
      end
    end
  end

  private
  def configure_test_environment(conn_string)
    env_yaml = <<EOS
---
env_name: 'test'
db:
  connection_string: #{conn_string}
  username: ''
  password: ''
version_log_table_name:  'spec_version_log'
schema_name: 'spec_schema'
variables:
...
EOS
    filename = File.join(@test_root_dir, @test_dir, 'environments', 'test.yaml')
    File.open(filename, 'wb') {|f| f.write(env_yaml) }
  end

  def configure_test_environment_with_variables(conn_string)
    env_yaml = <<EOS
---
env_name: 'test'
db:
  connection_string: #{conn_string}
  username: ''
  password: ''
version_log_table_name:  'spec_version_log'
schema_name: 'spec_schema'
variables:
  test_var1: 'foobar'
  test_var2: '6'
...
EOS
    filename = File.join(@test_root_dir, @test_dir, 'environments', 'test.yaml')
    File.open(filename, 'wb') {|f| f.write(env_yaml) }
  end

  def create_bootstrap_migration
    sql = "CREATE TABLE foo(id varchar(45));"
    File.open(File.join(@test_root_dir, @test_dir, 'bootstrap', '01_bootstrap.sql'), 'wb') {|f| f.write(sql) }
  end

  def create_a_test_migration(comment, *scripts)
    time_now = Time.new
    migration_id = time_now.strftime('%Y%m%d_%H%M%S')

    Time.stub!(:now).and_return(time_now)

    @sut.add comment

    i = 10
    scripts.flatten!
    scripts.each do |script|
      filename = File.join(@test_root_dir, @test_dir, 'migrations', migration_id, "#{i}_test_script.sql")
      File.open(filename, 'wb') {|f| f.write(script)}
      i = i+1
    end unless scripts.nil?

    migration_id
  end

  def create_sample_migration_1
    scripts = []
    scripts << <<EOL
--
--DROP TABLE %{schema_name}.FOOBAR;
--DROP SEQUENCE %{schema_name}.FOOBAR;
--
-- create table
CREATE TABLE %{schema_name}.FOOBAR(FOO_ID BIGINT NOT NULL, NAME VARCHAR(250), CODE VARCHAR(250), PROCESS_STATE VARCHAR(30));
--
--
EOL

scripts << <<EOL
-- insert data
INSERT INTO %{schema_name}.%{test_var1} (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2247,'bazbazbazbaz','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2248,'barbarbarbar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2221,'foofoofoofoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2222,'bazfoobaz','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2250,'bazbazfoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2118,'bazfoofoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2119,'barfoobar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2120,'barbarfoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2121,'barfoofoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2124,'foobarfoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2125,'foobarbar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2126,'wanwanwan','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2127,'bazbazbaz','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2159,'barbarbar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2160,'foofoofoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2172,'baz world','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2173,'bar world','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2174,'foo world','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2179,'hello foo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2180,'hello baz','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2182,'hello bar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2183,'hello wan','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2185,'hello blah','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2186,'hello world','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2241,'bazwan','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2246,'wanbar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2112,'foowan','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2113,'wanblah','1232112314', 'Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2249,'blahhhhh','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2244,'fooblah','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2245,'blahfoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2255,'bazbar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2256,'barfoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2257,'foobar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2133,'foofoo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2258,'foo','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2259,'bazbaz','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2132,'baz','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (-1,'','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2187,'barbar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2188,'bar','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2189,'blahblah','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2242,'blah','1232112314','Y');
INSERT INTO %{schema_name}.FOOBAR (FOO_ID, NAME, CODE, PROCESS_STATE) VALUES (2263,'buzzzzzz','1232112314','Y');
EOL
    create_a_test_migration 'test create and insert data', scripts
  end

  def create_sample_migration_2
    scripts = []
    scripts << <<EOL
--
-- create sequence
CREATE SEQUENCE %{schema_name}.FOOBAR_SEQ
  START WITH 1
  MAXVALUE 99999999
  MINVALUE 0;
--
-- create constraint
ALTER TABLE %{schema_name}.FOOBAR
ADD PRIMARY KEY(FOO_ID);
EOL

    create_a_test_migration 'test create a sproc, sequence, and constraint', scripts
  end
end
