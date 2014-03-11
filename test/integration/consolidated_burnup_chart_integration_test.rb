require File.join(File.dirname(__FILE__), 'integration_test_helper')

# The Mingle API supports basic authentication and must be used in order to run integration tests. 
# However it is disabled in the default configuration. To enable basic authentication, 
# you need set the basic_authentication_enabled configuration option to true in the 
# <mingle_data_directory>/config/auth_config.yml file where <mingle_data_directory> is the path 
# to the mingle data directory on your installation e.g.
# basic_authentication_enabled: true.

class ConsolidatedBurnupChartIntegrationTest < Test::Unit::TestCase

  PROJECT_RESOURCE = 'http://username:password@your.mingle.server:port/api/v2/lightweight_projects/macro_toolkit_test.xml'
  ANOTHER_PROJECT_RESOURCE = 'http://username:password@your.mingle.server:port/api/v2/lightweight_projects/macro_toolkit_test.xml'
  
  def test_macro_contents
    consolidated_burnup_chart = ConsolidatedBurnupChart.new(nil, project(PROJECT_RESOURCE), nil)
    result = consolidated_burnup_chart.execute
    assert result
  end
  
  def test_macro_contents_with_a_project_group
    consolidated_burnup_chart = ConsolidatedBurnupChart.new(nil, [project(PROJECT_RESOURCE), project(ANOTHER_PROJECT_RESOURCE)], nil)
    result = consolidated_burnup_chart.execute
    assert result
  end
end