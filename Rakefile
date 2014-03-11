namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.libs << "test/unit"
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << "test/integration"
    t.pattern = 'test/integration/*_test.rb'
    t.verbose = true
  end
end

namespace :macro do |ns|
  task :deploy, :mingle_location do |task|
    macro_folder = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    mingle_location = task[:mingle_location] || ENV["MINGLE_LOCATION"]
    mingle_plugins_folder = File.join(mingle_location, 'vendor', 'plugins')
    FileUtils.cp_r(macro_folder, mingle_plugins_folder)
    puts "#{macro_folder} successfully copied over to #{mingle_plugins_folder}. Restart the Mingle server to start using the macro."
  end
end