class ConsolidatedBurnupChart
  require 'pp'

  def initialize(parameters, project, current_user)
    @parameters = parameters
    @project = project
    @current_user = current_user
    @series_info = []
    @date_array = []
    @chart_height = @parameters['height'] || '500px'
    @chart_width = @parameters['width'] || '900px'
    @y_axis_label = @parameters['y-axis-label'] || ""
  end

  def get_dates
    start_date = Date.parse(@parameters['start-date'])
    end_date = Date.parse(@parameters['end-date'])
    start_date.step(end_date, step = @parameters['x-label-step'].to_i){ |date|
      @date_array << date
    }
  end

  def format_parameters
    @parameters['series'].each do |project|
     @series_info << {  :project_name => project['project'],
        :total_scope_query => project['total-scope-query'], 
        :completed_scope_query => project['completed-scope-query'], 
     }
    end
  end

  def add_date_to_query
    dates = @date_array.sort!

    @series_info.each do |series|
      dated_total_scope_queries = []
      dated_completed_scope_queries = []
      
      dates.each do |date|
        dated_total_scope_queries << series[:total_scope_query].split(/where/).insert(1, "AS OF '#{date}' WHERE").join
        dated_completed_scope_queries << series[:completed_scope_query].split(/where/).insert(1, "AS OF '#{date}' WHERE").join
      end

      series[:total_scope_query] = dated_total_scope_queries
      series[:completed_scope_query] = dated_completed_scope_queries
    end
  end


  def get_scope_values
    @series_info.each do |project|

      uri = URI.parse("http://sarah:p@localhost:8080/api/v2/projects/#{project[:project_name]}/cards/execute_mql.json")

      project.shift

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
        
      returned_value_array = []


      project[:total_scope_query].map! do |query|

        request.form_data = {:mql => query}
        response = http.request(request)     
        body = response.body
        
        returned_value = JSON.parse(body).first.values
        
        query = returned_value[0].to_i
      end

      project[:completed_scope_query].map! do |query|

        request.form_data = {:mql => query}
        response = http.request(request)     
        body = response.body
        
        returned_value = JSON.parse(body).first.values
        
        query = returned_value[0].to_i
      end

    end
  end

  def consolidate_scope_data
    final_data_structure = []
    total_scope_queries = []
    completed_scope_queries = []

    @series_info.each do |query|
      total_scope_queries << query[:total_scope_query]
      completed_scope_queries << query[:completed_scope_query]
    end

    final_data_structure << total_scope_queries.transpose.map! {|x| x.reduce(:+)}
    final_data_structure << completed_scope_queries.transpose.map! {|x| x.reduce(:+)}

    return final_data_structure
    end

    def construct_final
      header = ["Date", "Total Scope", "Completed Scope"]
      @date_array.map! {|date| date.to_s.split('-').collect{|x| x.to_i}}
     
      project_data = consolidate_scope_data.transpose
      dates_and_data = @date_array.zip(project_data)
      dates_and_data.each {|x| x.flatten!}
      dates_and_data.unshift(header)

      return dates_and_data
  end

  def execute
     get_dates
     format_parameters
     add_date_to_query
     get_scope_values

    %{
     

      <div id="chart_div" style="width: #{@chart_width}; height: #{@chart_height};"></div>
      
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript"> 
        google.load("visualization", "1", {packages:["corechart"]});
        google.setOnLoadCallback(drawChart);

        function formatDates() {
         var dataArray = #{construct_final.to_json};
         for(var i=1; i < dataArray.length; i++){
            var dateSetUp = dataArray[i].splice(0,3);
            var dateObject = new Date(dateSetUp);
            dataArray[i].unshift(dateObject);
          };
          return(dataArray);
        };

        function drawChart() {
          var data = google.visualization.arrayToDataTable( formatDates() );
          var options = {
            title: 'Consolidated Burn Up',
            trendlines: { 1: {} }
          };

          var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
          chart.draw(data, options);
        };
      
      </script>

    }
    
  end

    
end