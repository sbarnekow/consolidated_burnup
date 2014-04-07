require 'rubygems'

require 'uri'
require 'net/http'
require 'json'
require 'time'
require 'date'
require 'pp'

	# date_array = ["01-02-2014", "01-03-2014", "01-04-2014"]

	series_info = 
	# doesn't work for identical keys
		{
			"cc" => {
		 	  :total_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'UCL'", 
		      :completed_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'UCL' AND SimpleStatus = Done"
		  	},
		  	"dvip" => {
		      :total_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'ad pack'", 
		      :completed_scope_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'ad pack' AND SimpleStatus = Done"
		  	},
		  	"ddba" => {
		      :total_scope_query => "SELECT sum('Story Points') where type = Story", 
		      :completed_scope_query => "SELECT sum('Story Points') where type = Story AND SimpleStatus = Done"
		  	}  
		}

	# this method gets the dates based on start, end, and x-label-step using a ruby step method for dates
	def get_dates
	    start_date = Date.parse("01-02-2014")
	    end_date = Date.parse("01-05-2014")
	    date_array = []
	    start_date.step(end_date, step = 15){ |date|
	      date_array << date
	    }
	    return date_array
  	end

  	dates = get_dates

	def define_statements(series_hash, date_array)
	   # sort the project array alphabetically to protect it from arbitrary order
	   project_array = series_hash.keys.sort!
	   # sort the date array for the same reason
	   dates = date_array.sort!

	   project_query_constructor = {}

	  	# for each project, create a new constructor hash and an empty array for the newly formed queries
	  	project_array.each do |project|
	  		project_query_constructor[project] ||= {} 
			dated_query_array = []
			# take the series object and for each date in the date array, split on "where" and insert the date statement
			series_hash[project].each do |query|
	    		dates.each do |date|
		    		dated_query_array << query[1].split(/where/).insert(1, "AS OF '#{date}' WHERE").join
		    	end
		    end
		    # match the project names to their respective the dated querys
		    project_query_constructor[project] = dated_query_array 
		end

		return project_query_constructor
	end

	constructed_queries = define_statements(series_info, dates)


	def get_scope(project_query_hash)
	 	completed_queries = []
	    counter = 0

	    project_query_hash.each do |key, query_array|

	    	uri = URI.parse("http://sarah:p@localhost:8080/api/v2/projects/#{key}/cards/execute_mql.json")

	    	http = Net::HTTP.new(uri.host, uri.port)
	    	request = Net::HTTP::Get.new(uri.request_uri)

	    	value_array = []

	    	# takes each constructed query and makes the GET request based on the MQL statement, storing each response in an array
	    	# that response array is then pushed to a bigger value array, completed_queries
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

	   # completed_queries is an array composed of an array of mql values for each series
	   # each array will be the same length and then transposed at the same indices so that 
	   # each date's query for either :total_scope_query and :completed_scope_query will be contained within the same array 
	   # for each item in completed_queries (an array for each date and corresponding query type) 
	   # map adds all of the items in the array together with x.reduce(:+)
	   # thus resulting in the reduced array titled reduced_query

	   reduced_query = completed_queries.transpose.map! {|x| x.reduce(:+)}
	   
	   return reduced_query
	end

	scope = get_scope(constructed_queries)


	def construct_final(dates, query_results)
		query_categories = [:total_scope_query, :completed_scope_query]
		
		#splits the array in two, one for :total_scope_query and one for :completed_scope_query
		# eg. [[34, 262, 505, 560, 560, 560], [12, 107, 206, 227, 227, 227]]
		queries_by_date = query_results.each_slice(dates.length).to_a
		
		header = ["Date", "Total Scope", "Completed Scope"]

		# splits date values out into arrays to be processed by javascript
		# so that the values can be mapped to them
		# eg. [[2014, 2, 1],
		#  [2014, 2, 16],
		#  [2014, 3, 3],
		#  [2014, 3, 18],
		#  [2014, 4, 2],
		#  [2014, 4, 17]]

		initial_arr = dates.map{|date| date.to_s.split('-').collect{|x| x.to_i}}

		# now transposing :total_scope_query and :completed_scope_query to prepare each value to be mapped to the correct date
		# [[34, 12], [262, 107], [505, 206], [560, 227], [560, 227], [560, 227]]
		queries_arr = queries_by_date.transpose

		# adds date_array to the query results array to be mapped in the way the google maps API takes them
		# eg. [[[2014, 2, 1], [34, 12]],
		#  [[2014, 2, 16], [262, 107]],
		#  [[2014, 3, 3], [505, 206]],
		#  [[2014, 3, 18], [560, 227]],
		#  [[2014, 4, 2], [560, 227]],
		#  [[2014, 4, 17], [560, 227]]]
		final_arr = initial_arr.zip(queries_arr)

		# flattens the array into a google maps readable format
		# eg [[2014, 2, 1, 34, 12],
		#  [2014, 2, 16, 262, 107],
		#  [2014, 3, 3, 505, 206],
		#  [2014, 3, 18, 560, 227],
		#  [2014, 4, 2, 560, 227],
		#  [2014, 4, 17, 560, 227]]
		final_arr.each do |x|
			x.flatten!
		end

		# adds the header to the front of the array
		final_arr.unshift(header)
		
		return final_arr
	end

	final_data = construct_final(dates, scope)

	def render_chart(arr)
		%{

	      <div id="chart_div" style="width: 900px; height: 500px;"></div>
	      
	      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
	      <script type="text/javascript">
	        google.load("visualization", "1", {packages:["corechart"]});
	        google.setOnLoadCallback(drawChart);
	      
	      	function formatDates(){
	      		debugger;
	      		var dataArray = #{arr};

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
	outtext = render_chart(final_data)
	outfile.puts(outtext)
	outfile.close

