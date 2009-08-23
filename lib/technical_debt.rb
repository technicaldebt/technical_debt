require 'rubygems'
require 'active_support'
require 'timeout'
require 'net/http'
require 'uri'

class TechnicalDebt

  def initialize(dir)
    @project = dir
  end
  
  def project
    @project
  end
  
  def git_version
    `git --version`.gsub(/git version/, "").strip
  end
  
  def last_commit_sha
    `git rev-parse head`.strip
  end
  
  def minimum_git_version?
    git_version >= "1.6"
  end
  
  def last_commit
    `git diff master~1 head`
  end
  
  def get_git_token
    `git config --global technicaldebt.token`.strip
  end
  
  def git_token_exists?
    !get_git_token.blank?
  end
  
  def split_commit
    last_commit.split("\n")
  end
  
  def regex_debt_matcher
    /^\+\s*#\s*[dD][eE][bB][tT]\s+(.*)$*/
  end
  
  #DEBT
  def committed_lines_only
    split_commit.reject { |commited_line| !(commited_line =~ /^\+[^\+]/)}
  end
  
  def debt_lines_only
    committed_lines_only.reject{ |committed_line| !(committed_line =~ regex_debt_matcher)}
  end
  
  def debt_lines_with_logged
    if log_file_exists?
      debt = debt_lines_only + read_logged_debt
      File.delete(log_file)
    else
      debt = debt_lines_only
    end
    debt
  end
  
  def push_to_technical_debt
    debt_lines_with_logged.each do |debt_line|
      send_to_server(debt_line)
    end
  end

  def check_connection
    begin
      status = Timeout::timeout(2){
        Net::HTTP.get(URI.parse("http://google.com"))
        return true
      }
    rescue Exception
      return false
    end
  end

  def connection_exists?
    check_connection ? true : false
  end
  
  def register_debt
    if git_token_exists? && connection_exists? && !debt_lines_with_logged.blank?
      push_to_technical_debt
    else
      log_debt
    end
  end
  

  def log_debt
    File.open(log_file, 'a') { |f| f.write(debt_lines_only.join(",") + ",")}
    no_token_message unless git_token_exists?
  end

  def no_token_message
    puts "You don't have a token for Technical Debt access. To install it get your token from the website and:\ngit config --global technicaldebt.token your_token_here\nVisit http://technicaldebt.r09.railsrumble.com/account to obtain your token\n"
  end
  
  def log_file_exists?
    File.exists?("#{project}/.git/technical_debt")
  end
  
  def read_logged_debt
    File.open(log_file,'r') { |f| f.read.split(",")}
  end
  
  #DEBT 1h Just a sanity check maybe a reality check
  def log_file
    "#{project}/.git/technical_debt"
  end
  
  def send_to_server(debt)
    Net::HTTP.post_form(URI.parse("http://technicaldebt.r09.railsrumble.com/transactions"),  { 'transaction[message]' => stripped_debt_line(debt), 'transaction[sha]' => last_commit_sha, 'git_token' => get_git_token, 'kind' => 'debt' })
  end
  
  def stripped_debt_line(debt_line)
    debt_line[/^\+\s*#\s*[dD][eE][bB][tT]\s+(.*)$/, 1]
  end
  
  def debtify
    path = File.expand_path(project.to_s)
    command = "#/bin/sh\ncd #{path} && senddebt ."
    post_commit_file = "#{path}/.git/hooks/post-commit"
    File.open(post_commit_file,'w'){ |f| f.write(command) }
    File.chmod(0755, post_commit_file)
    puts "Your project is now debtified."
  end
  
end