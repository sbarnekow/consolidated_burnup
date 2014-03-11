require File.join(File.dirname(__FILE__), "..", "test_helper")
FixtureLoaders::FIXTURE_PATH = File.join(File.dirname(__FILE__), "..", "data", "fixtures")

class Test::Unit::TestCase
  def project(name)
    @projects ||= {}
    @projects[name] ||= FixtureLoaders::ProjectLoader.new(name).project
  end

  def projects(*resources)
    resources.collect {|resource| project(resource)}
  end
end