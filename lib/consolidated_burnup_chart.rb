
  # given parameters
  #  - project
  #  - card
  #  - count related story points via MQL
  # api call 
  #   - see if *status* date is set 
  #   - if it is, execute MQL
  #   - plot results of MQL corresponding to date on chart

class ConsolidatedBurnupChart
  require 'json'

  def initialize(parameters, project, current_user)
    @parameters = parameters
    @project = project
    @current_user = current_user
  end

  def execute
    data_to_render = retrieve_data
    render_chart(data_to_render)
  end

  def render_chart(render_this)
    %{
        <div id="chart_div2" style="width: 900px; height: 500px;"> #{ @parameters } </div>
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
    return data_array = [
          ['Year', 'Sales'],
          ['1/1/2014',  1000],
          ['1/2/2014',  1170],
          ['1/3/2014',  660],
          ['1/4/2014',  1030]
        ]
  end

   # <div id="chart_div" style="width: 900px; height: 500px;"></div>
    #   <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    #   <script type="text/javascript">
    #     google.load("visualization", "1", {packages:["corechart"]});
    #     google.setOnLoadCallback(drawChart);
    #     function drawChart() {
    #       var data = google.visualization.arrayToDataTable([
    #         ['Day', 'Amount'],
    #         [new Date(2014, 1, 09),  0],
    #         [new Date(2014, 1, 10),  1000],
    #         [new Date(2014, 1, 11),  1170],
    #         [new Date(2014, 1, 12),  1220],
    #         [new Date(2014, 1, 13),  1300]
    #       ]);

    #       var options = {
    #         title: 'Test Chart',
    #         trendlines: { 0: {} }
    #       };

    #       var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
    #       chart.draw(data, options);
    #       }
    #   </script>

  # def render_chart(data_array)
  #   # <div id="chart_div" style="width: 900px; height: 500px;"></div>
  #   #   <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  #   #   <script type="text/javascript">
  #   #     google.load("visualization", "1", {packages:["corechart"]});
  #   #     google.setOnLoadCallback(drawChart);
  #   #     function drawChart() {
  #   #       var data = google.visualization.arrayToDataTable([
  #   #         ['Day', 'Amount'],
  #   #         [new Date(2014, 1, 09),  0],
  #   #         [new Date(2014, 1, 10),  1000],
  #   #         [new Date(2014, 1, 11),  1170],
  #   #         [new Date(2014, 1, 12),  1220],
  #   #         [new Date(2014, 1, 13),  1300]
  #   #       ]);

  #   #       var options = {
  #   #         title: 'Test Chart',
  #   #         trendlines: { 0: {} }
  #   #       };

  #   #       var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
  #   #       chart.draw(data, options);
  #   #       }
  #   #   </script>

  #   %{
  #      <div id="chart_div" style="width: 900px; height: 500px;"></div>
  #     <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  #     <script type="text/javascript">
  #       google.load("visualization", "1", {packages:["corechart"]});
  #       google.setOnLoadCallback(drawChart);
  #       function drawChart() {
  #         var data = google.visualization.arrayToDataTable(
  #               #{retrieve_data}
  #             );

  #         var options = {
  #           title: 'Test Chart',
  #           trendlines: { 0: {} }
  #         };

  #         var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
  #         chart.draw(data, options);
  #         }
  #     </script>
  #   }
  # end

  # def retrieve_data
  #   return data_array = [
  #       ['Day', 'Amount'],
  #       [new Date(2014, 1, 09),  0],
  #       [new Date(2014, 1, 10),  1000],
  #       [new Date(2014, 1, 11),  1170],
  #       [new Date(2014, 1, 12),  1220],
  #       [new Date(2014, 1, 13),  1300]
  #       ]
  # end

  
  # def can_be_cached?
  #   false  # if appropriate, switch to true once you move your macro to production
  # end
    
end

