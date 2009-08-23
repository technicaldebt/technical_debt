require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TechnicalDebt,"git_version" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end
  
  it "should check the git version if git exists" do
    @techdebt.git_version.should_not be_nil
  end
  
end

describe TechnicalDebt,"minimum_git_version?" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end
  
  it "should return true for 1.6 or higher" do
    @techdebt.stub!(:git_version).and_return("1.6.3.1")
    @techdebt.should be_minimum_git_version
  end
  
  it "should return false for anything less than 1.6" do
    @techdebt.stub!(:git_version).and_return("1.5.5.1")
    @techdebt.should_not be_minimum_git_version
  end
  
end

describe TechnicalDebt,"last_commit" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
    @techdebt.stub!(:project).and_return(`pwd`)
  end
  
  it "should return the last commit for the project" do
    @techdebt.last_commit.should include("diff --git")
  end
  
end

describe TechnicalDebt,"split_commit" do
  
  before do
    @techdebt = TechnicalDebt.new(ARGV)
    @techdebt.stub!(:last_commit).and_return(git_diff)
  end
  
  it "should split the git diff into an array of lines" do
    @techdebt.split_commit.should be_instance_of(Array)
  end
  
  it "should not be nil for the git diff array" do
    @techdebt.split_commit.should_not be_nil
  end
end

describe TechnicalDebt,"commited_lines_only" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
    @techdebt.stub!(:last_commit).and_return(git_diff)
  end
  
  it "should only keep lines that have one + at the start" do
    @techdebt.committed_lines_only.each do |line|
      line[0].should == 43
      line[1].should_not == 43
    end
  end
  
  it "should have lines in the commit" do
    @techdebt.committed_lines_only.size.should > 0
  end
  
end

describe TechnicalDebt,"debt_lines_only" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end
  
  it "should return 0 for a commit with no debt included in any lines" do
    @techdebt.stub!(:last_commit).and_return(git_diff)
    @techdebt.debt_lines_only.size.should == 0
  end

  it "should return the number of lines for a commit with no debt included in any lines" do
    @techdebt.stub!(:last_commit).and_return(git_diff_with_debt)
    @techdebt.debt_lines_only.size.should == 1
  end
  
end

describe TechnicalDebt do
  before do
    @argv = `pwd`
    @techdebt = TechnicalDebt.new(@argv)  
  end
  
  it "should make the project" do
    @techdebt.project.should == @argv
  end
  
end

describe TechnicalDebt,"push_to_technical_debt" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
    @techdebt.stub!(:last_commit).and_return(git_diff_with_debt)
    @techdebt.stub!(:send_to_server).and_return(true)
  end
  
  it "send information to technical debt" do
    @techdebt.should_receive(:send_to_server).exactly(@techdebt.debt_lines_only.size).times
    @techdebt.push_to_technical_debt
  end
  
end

describe TechnicalDebt,"connection_exists?" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end  
  
  it "should return true if we can get to the net" do
    @techdebt.stub!(:check_connection).and_return(true)
    @techdebt.should be_connection_exists
  end

  
  it "should return false if it times out" do
    @techdebt.stub!(:check_connection).and_return(false)
    @techdebt.should_not be_connection_exists
  end
  
end

describe TechnicalDebt,"register_debt" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end
  
  it "should call push to technical debt if there is a connection and git_token_exists?" do
    @techdebt.stub!(:check_connection).and_return(true)
    @techdebt.stub!(:git_token_exists?).and_return(true)
    @techdebt.should_receive(:push_to_technical_debt)
    @techdebt.register_debt
  end
  
  it "should log to a file if there is no connection" do
    @techdebt.stub!(:check_connection).and_return(false)
    @techdebt.stub!(:git_token_exists?).and_return(true)
    @techdebt.should_receive(:log_debt)
    @techdebt.register_debt
  end
  
  it "should log to a file if there is no git_token" do
    @techdebt.stub!(:check_connection).and_return(true)
    @techdebt.stub!(:git_token_exists?).and_return(false)
    @techdebt.should_receive(:log_debt)
    @techdebt.register_debt
  end
  
end

describe TechnicalDebt,"log_debt" do
  before do
    @arg = `pwd`
    @techdebt = TechnicalDebt.new(@arg)
  end
  
  it "should write to the existing file if it's here" do
    File.stub!(:open)
    File.should_receive(:open).with(@techdebt.log_file, 'a')
    @techdebt.log_debt
  end
  
end

describe TechnicalDebt,"log_file_exists?" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end
  
  it "should call File.exists?" do
    File.should_receive(:exists?)
    @techdebt.log_file_exists?
  end
end

describe TechnicalDebt,"read existing data" do
  before do
    @arg = `pwd`
    @techdebt = TechnicalDebt.new(@arg)
  end
  
  it "should read the file" do
    File.should_receive(:open).with(@techdebt.log_file, 'r')
    @techdebt.read_logged_debt
  end
  
end

describe TechnicalDebt,"debt_lines_with_logged" do
  before do
    @arg = `pwd`
    @techdebt = TechnicalDebt.new(@arg)
    @techdebt.stub!(:log_file_exists?).and_return(true)
    @techdebt.stub!(:read_logged_debt).and_return(["+ #DEBT"])
    File.stub!(:delete)
  end
  
  it "should delete the file if it exists" do
    File.should_receive(:delete)
    @techdebt.debt_lines_with_logged
  end
  
end

describe TechnicalDebt,"strip # DEBT from debt lines" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
    @techdebt.stub!(:last_commit).and_return(git_diff_with_debt)
  end
  
  it "should not start with the word DEBT" do
    @techdebt.stripped_debt_line("+  #DEBT 1 hour Just a sanity check maybe a reality check, booooo, sigh").should_not include("+ #DEBT")
  end
  
end

describe TechnicalDebt,"git_token_exists?" do
  before do
    @techdebt = TechnicalDebt.new(ARGV)
  end
  
  it "should return true when the git_token is entered" do
    @techdebt.stub!(:get_git_token).and_return("eba45741fb2bd08580328d6b991a9b6a")
    @techdebt.should be_git_token_exists
  end
  
  it "should return false when the git token is empty" do
    @techdebt.stub!(:get_git_token).and_return("")
    @techdebt.should_not be_git_token_exists
  end
  
  it "should return false when the git token is nil" do
    @techdebt.stub!(:get_git_token).and_return(nil)
    @techdebt.should_not be_git_token_exists
  end
  
end