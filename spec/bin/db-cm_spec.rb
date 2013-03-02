require 'db-cm/commands'

describe Db::Cm::Commands do
  before :each do
    @test_dir="test_root"
    @sut = Db::Cm::Commands.new
    @test_root_dir = @sut.destination_root
  end 

  describe "#init" do
    before :each do      
      @sut.init @test_dir
    end

    after :each do
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir) 
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
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir) 
    end
    
    it "creates the migration root directory based on today's date" do      
      File.directory?(File.join(@test_root_dir, @test_dir, 'migrations', @dir_name)).should be_true
    end
    
    it "creates the version.txt based on the comment" do
      version_filename = File.join(@test_root_dir, @test_dir, 'migrations', @dir_name, 'version.txt')
      File.exists?(version_filename).should be_true
      version_contents = IO.read(version_filename)
      @comment.should eq version_contents
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
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir) 
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
      FileUtils.remove_dir File.join(@test_root_dir, @test_dir) 
    end

    it 'does not do anything if the bootstrap directory has no sql to run' do
      result = @sut.bootstrap 'test'
      result.should be_false
    end
    


    
    
    end
 
  
end



