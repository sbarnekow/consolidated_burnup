require 'rubygems'
require 'uri'
require 'net/http'
require 'json'
require 'time'
require 'date'
require 'pp'


@series = 
[{
	:project_name => "cc",
 	:total_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'UCL'", 
    :completed_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'UCL' AND SimpleStatus = Done"
},
{
	:project_name => "dvip",
    :total_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'ad pack'", 
    :completed_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'ad pack' AND SimpleStatus = Done"
},
{ 
	:project_name => "ddba",    
  	:total_scope_query => "SELECT sum('Story Points') where type = Story", 
  	:completed_scope_query => "SELECT sum('Story Points') where type = Story AND SimpleStatus = Done"
}]  

def compose_date_array
    start_date = Date.parse("01-02-2014")
    end_date = Date.parse("01-05-2014")
    @date_array = []
    start_date.step(end_date, step = 15){ |date|
      @date_array << date
    }
end

compose_date_array
pp @date_array

def add_date_to_query
	dates = @date_array.sort!

	@series.each do |series|
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

add_date_to_query
# pp @series

def get_scope_values
	@series.each do |project|

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

get_scope_values
# pp @series


def consolidate_scope_data
	final_data_structure = []
	total_scope_queries = []
	completed_scope_queries = []

	@series.each do |query|
		total_scope_queries << query[:total_scope_query]
		completed_scope_queries << query[:completed_scope_query]
	end

	final_data_structure << total_scope_queries.transpose.map! {|x| x.reduce(:+)}
	final_data_structure << completed_scope_queries.transpose.map! {|x| x.reduce(:+)}

	return final_data_structure
end

def construct_final_array
	header = ["Date", "Total Scope", "Completed Scope"]
	@date_array.map! {|date| date.to_s.split('-').collect{|x| x.to_i}}
	project_data = consolidate_scope_data.transpose
	dates_and_data = @date_array.zip(project_data)
	dates_and_data.each {|x| x.flatten!}
	dates_and_data.unshift(header)
	return dates_and_data
end

def render_chart
	%{

      <div id="chart_div" style="width: 900px; height: 500px;"></div>
      
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript">
        google.load("visualization", "1", {packages:["corechart"]});
        google.setOnLoadCallback(drawChart);
      
      	function formatDates(){
      		debugger;
      		var dataArray = #{construct_final_array};

      		 for(var i=1; i < dataArray.length; i++){
	            var dateSetUp = dataArray[i].splice(0,3);
	            var dateObject = new Date(dateSetUp);
	            dataArray[i].unshift(dateObject);
	          };
	          return dataArray
      	};

        function drawChart() {
          var data = google.visualization.arrayToDataTable( formatDates() );
          var options = {
            title: 'Consolidated Burn Up',
            trendlines: { 1: {} }
          };

          var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
          chart.draw(data, options);
        }
      </script>

		}

end

outfile = File.open('/Users/thoughtworker/Mingle/mingle_13_4_2/vendor/plugins/consolidated_burnup_chart/test.html', 'w')
outfile.puts('<HTML><head></head><body>')
outtext = render_chart
outfile.puts(outtext)
outfile.close

