module GitDiffs
  
  def git_diff
    "diff --git a/gem/techincal_debt/lib/techincal_debt.rb b/gem/techincal_debt/lib/techincal_debt.rb\nindex c8c56b2..04dd2e9 100644\n--- a/gem/techincal_debt/lib/techincal_debt.rb\n+++ b/gem/techincal_debt/lib/techincal_debt.rb\n@@ -7,4 +7,8 @@ class TechnicalDebt\n   def minimum_git_version?\n     git_version >= \"1.6\"\n   end\n+  \n+  def last_commit\n+    `git diff`\n+  end\n end\n\\ No newline at end of file\ndiff --git a/gem/techincal_debt/spec/spec_helper.rb b/gem/techincal_debt/spec/spec_helper.rb\nindex 50ed73c..cd7e0f6 100644\n--- a/gem/techincal_debt/spec/spec_helper.rb\n+++ b/gem/techincal_debt/spec/spec_helper.rb\n@@ -1,9 +1,9 @@\n $LOAD_PATH.unshift(File.dirname(__FILE__))\n $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))\n-require 'techincaldebt'\n+require 'techincal_debt'\n require 'spec'\n require 'spec/autorun'\n \n Spec::Runner.configure do |config|\n-  \n+  include GitDiffs\n end\ndiff --git a/gem/techincal_debt/spec/techincal_debt_spec.rb b/gem/techincal_debt/spec/techincal_debt_spec.rb\nindex 13c4a63..d3cf868 100644\n--- a/gem/techincal_debt/spec/techincal_debt_spec.rb\n+++ b/gem/techincal_debt/spec/techincal_debt_spec.rb\n@@ -27,3 +27,22 @@ describe TechnicalDebt,\"minimum_git_version?\" do\n   end\n   \n end\n+\n+describe TechnicalDebt,\"last_commit\" do\n+  before do\n+    @techdebt = TechnicalDebt.new\n+    @techdebt.stub!(:project).and_return(`pwd`)\n+  end\n+  \n+  it \"should return the last commit for the project\" do\n+    @techdebt.last_commit.should include(\"diff --git\")\n+  end\n+  \n+end\n+\n+describe TechnicalDebt,\"split_commit\" do\n+  before do\n+    @techdebt = TechnicalDebt.new\n+    @techdebt.stub!(:last_commit).and_return()\n+  end\n+end\n\\ No newline at end of file\n"
  end
  
  def git_diff_with_debt
    "diff --git a/gem/techincal_debt/lib/techincal_debt.rb b/gem/techincal_debt/lib/techincal_debt.rb\nindex c8c56b2..04dd2e9 100644\n--- a/gem/techincal_debt/lib/techincal_debt.rb\n+++ b/gem/techincal_debt/lib/techincal_debt.rb\n@@ -7,4 +7,8 @@ class TechnicalDebt\n   def minimum_git_version?\n     git_version >= \"1.6\"\n   end\n+  \n+  def last_commit\n+    `git diff`\n+  end\n end\n\\ No newline at end of file\ndiff --git a/gem/techincal_debt/spec/spec_helper.rb b/gem/techincal_debt/spec/spec_helper.rb\nindex 50ed73c..cd7e0f6 100644\n--- a/gem/techincal_debt/spec/spec_helper.rb\n+++ b/gem/techincal_debt/spec/spec_helper.rb\n@@ -1,9 +1,9 @@\n $LOAD_PATH.unshift(File.dirname(__FILE__))\n $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))\n-require 'techincaldebt'\n+require 'techincal_debt'\n require 'spec'\n require 'spec/autorun'\n \n Spec::Runner.configure do |config|\n-  \n+  include GitDiffs\n end\ndiff --git a/gem/techincal_debt/spec/techincal_debt_spec.rb b/gem/techincal_debt/spec/techincal_debt_spec.rb\nindex 13c4a63..d3cf868 100644\n--- a/gem/techincal_debt/spec/techincal_debt_spec.rb\n+++ b/gem/techincal_debt/spec/techincal_debt_spec.rb\n@@ -27,3 +27,22 @@ describe TechnicalDebt,\"minimum_git_version?\" do\n   end\n   \n end\n+\n+describe TechnicalDebt,\"last_commit\" do\n+  before do\n+  #DEBT  @techdebt = TechnicalDebt.new\n+    @techdebt.stub!(:project).and_return(`pwd`)\n+  end\n+  \n+  it \"should return the last commit for the project\" do\n+    @techdebt.last_commit.should include(\"diff --git\")\n+  end\n+  \n+end\n+\n+describe TechnicalDebt,\"split_commit\" do\n+  before do\n+    @techdebt = TechnicalDebt.new\n+    @techdebt.stub!(:last_commit).and_return()\n+  end\n+end\n\\ No newline at end of file\n"
  end

  def git_diff_with_debt_start_end
    "diff --git a/gem/techincal_debt/lib/techincal_debt.rb b/gem/techincal_debt/lib/techincal_debt.rb\nindex c8c56b2..04dd2e9 100644\n--- a/gem/techincal_debt/lib/techincal_debt.rb\n+++ b/gem/techincal_debt/lib/techincal_debt.rb\n@@ -7,4 +7,8 @@ class TechnicalDebt\n   def minimum_git_version?\n     git_version >= \"1.6\"\n   end\n+  \n+  def last_commit\n+    `git diff`\n+  end\n end\n\\ No newline at end of file\ndiff --git a/gem/techincal_debt/spec/spec_helper.rb b/gem/techincal_debt/spec/spec_helper.rb\nindex 50ed73c..cd7e0f6 100644\n--- a/gem/techincal_debt/spec/spec_helper.rb\n+++ b/gem/techincal_debt/spec/spec_helper.rb\n@@ -1,9 +1,9 @@\n $LOAD_PATH.unshift(File.dirname(__FILE__))\n $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))\n-require 'techincaldebt'\n+require 'techincal_debt'\n require 'spec'\n require 'spec/autorun'\n \n Spec::Runner.configure do |config|\n-  \n+  include GitDiffs\n end\ndiff --git a/gem/techincal_debt/spec/techincal_debt_spec.rb b/gem/techincal_debt/spec/techincal_debt_spec.rb\nindex 13c4a63..d3cf868 100644\n--- a/gem/techincal_debt/spec/techincal_debt_spec.rb\n+++ b/gem/techincal_debt/spec/techincal_debt_spec.rb\n@@ -27,3 +27,22 @@ describe TechnicalDebt,\"minimum_git_version?\" do\n   end\n   \n end\n+\n+describe TechnicalDebt,\"last_commit\" do\n+  before do\n+  #STARTDEBT  @techdebt = TechnicalDebt.new\n+    @techdebt.stub!(:project).and_return(`pwd`)\n+  #ENDDEBT end\n+  \n+  it \"should return the last commit for the project\" do\n+    @techdebt.last_commit.should include(\"diff --git\")\n+  end\n+  \n+end\n+\n+describe TechnicalDebt,\"split_commit\" do\n+  before do\n+    @techdebt = TechnicalDebt.new\n+    @techdebt.stub!(:last_commit).and_return()\n+  end\n+end\n\\ No newline at end of file\n"
  end
  
end