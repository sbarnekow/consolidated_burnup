require 'date'
require 'json'

# date_array = [DateTime.new(2014, 1, 10)]

# def get_dates(array_of_dates)
#   new_date = array_of_dates[-1] + 5

#   if new_date < (DateTime.new(2014, 1, 23))
#     array_of_dates.push(new_date)
#     get_dates(array_of_dates)
#   else
#     array_of_dates.push(DateTime.new(2014, 1, 23))
#     return array_of_dates.sort!
#   end

# end


def render_chart(render_this)
  %{
      <div id="chart_div" style="width: 900px; height: 500px;"></div>
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable( #{render_this.to_json} );

        var options = {
          title: 'Test Chart',
          trendlines: { 0: {} }
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
        }
      </script>
  }
end

def retrieve_data
  #get a set of data for each project, using date array
  #push that set of date to the corresponding arrays within data_array
  #for project 1 would go to [1][1], [2][1], [3][1], [4][1] 
  #project 2 would go to [1][2], [2][2], [3][2], [4][2]
    return data_array = [
            ['Day', 'Amount'],
            [DateTime.parse('2014/1/09'),  0],
            [DateTime.parse('2014/1/10'),  1000],
            [DateTime.parse('2014/1/11'),  1170],
            [DateTime.parse('2014/1/12'),  1220],
            [DateTime.parse('2014/1/13'),  1300]
        ]
end


# DateTime.parse('2014/1/1')
# def execute
#     data_to_render = retrieve_data
#     puts render_chart(data_to_render)
# end


outfile = File.open('/Users/thoughtworker/Mingle/mingle_13_4_2/vendor/plugins/consolidated_burnup_chart/test.html', 'w')
outfile.puts('<HTML><head></head><body>')
data_to_render = retrieve_data
outtext = render_chart(data_to_render)
outfile.puts(outtext)
outfile.close