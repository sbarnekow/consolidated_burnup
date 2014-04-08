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
     {  :project_name => project['project']
        :total_scope_query => project['total-scope-query'], 
        :completed_scope_query => project['completed-scope-query'], 
     }
    end
  end

  def define_statements
    project_array = @series_info.keys.sort!
    dates = @date_array.sort!

      project_query_constructor = {}

      project_array.each do |project|
        project_query_constructor[project] ||= {} 
        dated_query_array = []
        @series_info[project].each do |query|
            dates.each do |date|
              dated_query_array << query[1].split(/where/).insert(1, "AS OF '#{date}' WHERE").join
            end
        end

        project_query_constructor[project] = dated_query_array 
      end

    return project_query_constructor
  end


  def get_scope
    project_queries = define_statements
    completed_queries = []
    counter = 0

      project_queries.each do |key, query_array|
        uri = URI.parse("http://sarah:p@localhost:8080/api/v2/projects/#{key}/cards/execute_mql.json")

        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)

        value_array = []

        query_array.each do |query|
          request.form_data = {:mql => query}
          response = http.request(request)     
          body = response.body
          obj = JSON.parse(body).first.values
     
          query_value = obj[0].to_i
          value_array << query_value
        end

        completed_queries << value_array
      end

      reduced_query = completed_queries.transpose.map! {|x| x.reduce(:+)}

      return reduced_query
  end

  def construct_final(query_results)
    query_categories = [:total_scope_query, :completed_scope_query]
    queries_by_date = query_results.each_slice(@date_array.length).to_a
    header = ["Date", "Total Scope", "Completed Scope"]

    js_structured_dates = @date_array.map{|date| date.to_s.split('-').collect{|x| x.to_i}}

    js_structured_data = queries_by_date.transpose

    js_structured_array = js_structured_dates.zip(js_structured_data)

    js_structured_array.each do |x|
      x.flatten!
    end

    js_structured_array.unshift(header)
    
    return js_structured_array
  end

  def execute
     get_dates
     format_parameters
     define_statements
     scope = get_scope(define_statements)
    %{
     

      <div id="chart_div" style="width: #{@chart_width}; height: #{@chart_height};"></div>
      
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript"> 
        google.load("visualization", "1", {packages:["corechart"]});
        google.setOnLoadCallback(drawChart);

        function formatDates() {
         var dataArray = #{construct_final(scope).to_json};
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