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

    it "creates the @test_dir/migrations/versionlog sub-directory" do
      File.directory?(File.join(@test_root_dir, @test_dir, 'migrations', 'versionlog')).should be_true
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

    it "creates the @test_dir/migrations/versionlog/custom_01.sql" do
      File.exists?(File.join(@test_root_dir, @test_dir, 'bootstrap', 'custom_01.sql')).should be_true
    end

    
  end
end



