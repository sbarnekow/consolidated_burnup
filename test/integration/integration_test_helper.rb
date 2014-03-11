#Copyright 2007 - 2013 ThoughtWorks, Inc.  All rights reserved.

require File.join(File.dirname(__FILE__), "..", "test_helper")

class Test::Unit::TestCase
  
  def project(resource)
    @projects ||= {}
    @projects[resource] ||= RESTfulLoaders::ProjectLoader.new(resource, self).project
  end
  
  def projects(*resources)
    resources.collect {|resource| project(resource)}
  end
  
  def errors
    @errors ||= []
  end
  
  def alert(message)
    errors << message
  end
end
