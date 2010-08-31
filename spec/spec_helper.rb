require "rubygems"

require "fileutils"
require "pathname"

class Pathname
  
  def touch(mtime = nil)
    FileUtils.touch(self.to_s)
    utime(mtime, mtime) if mtime
  end
  
end
  
$project_dir = Pathname(__FILE__).expand_path.parent.parent
$tmp_dir = $project_dir + "tmp"
$input_dir = $tmp_dir + "input"
$output_dir = $tmp_dir + "output"

Spec::Runner.configure do |config|

  config.before(:suite) do
    [$input_dir, $output_dir].each do |dir|
      dir.rmtree if dir.exist?
    end
  end
  
end
