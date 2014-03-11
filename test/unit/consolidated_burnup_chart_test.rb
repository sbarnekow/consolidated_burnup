require File.join(File.dirname(__FILE__), 'unit_test_helper')

class ConsolidatedBurnupChartTest < Test::Unit::TestCase

  PROJECT = 'scrum_template_2_1'

  def test_macro_contents
    consolidated_burnup_chart = ConsolidatedBurnupChart.new(nil, project(PROJECT), nil)
    result = consolidated_burnup_chart.execute
    assert result
  end

  def test_macro_contents_with_a_project_group
    consolidated_burnup_chart = ConsolidatedBurnupChart.new(nil, [project(PROJECT), project(PROJECT)], nil)
    result = consolidated_burnup_chart.execute
    assert result
  end

end
