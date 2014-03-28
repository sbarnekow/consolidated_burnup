require 'rubygems'

require 'uri'
require 'net/http'
require 'json'
require 'time'
require 'date'
require 'pp'

	# date_array = ["01-02-2014", "01-03-2014", "01-04-2014"]

	series_info = 
		{
			"cc" => {
		 	  :total_scope_query => "SELECT sum('Hours Remaining') where type = Story and 'Carfax Initiative' = 'UCL'", 
		      :completed_scope_query => "SELECT sum('Hours Remaining') where type = Story and 'Carfax Initiative' = 'UCL' AND SimpleStatus = Done", 
		      :actual_completed_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'UCL' AND SimpleStatus = Done"
		  	},
		  	"dvip" => {
		      :total_scope_query => "SELECT sum('Hours Remaining') where type = Story and 'Carfax Initiative' = 'ad pack'", 
		      :completed_scope_query => "SELECT sum('Hours Remaining') where type = Story and 'Carfax Initiative' = 'ad pack' AND SimpleStatus = Done", 
		      :actual_completed_query => "SELECT sum('Story Points') where type = Story and 'Carfax Initiative' = 'ad pack' AND SimpleStatus = Done"
		  	} 
		}

	def get_dates
	    start_date = Date.parse("01-02-2014")
	    end_date = Date.parse("01-04-2014")
	    date_array = []
	    start_date.step(end_date, step = 15){ |date|
	      date_array << date
	    }
	    return date_array
  	end

  	dates = get_dates

	def define_statements(series_hash, date_array)
	   project_array = series_hash.keys.sort!

	   dates = date_array.sort!

	  	project_query_constructor = {}

	  	project_array.each do |project|
	  		project_query_constructor[project] ||= {} 
			dated_query_array = []
			series_hash[project].each do |query|
	    		dates.each do |date|
		    		dated_query_array << query[1].split(/where/).insert(1, "AS OF '#{date}' WHERE").join
		    	end
		    end
		    project_query_constructor[project] = dated_query_array 
		end
		return project_query_constructor
	end

	constructed_queries = define_statements(series_info, dates)


	def get_scope(project_query_hash)
	 	completed_queries = []
	    counter = 0

	    project_query_hash.each do |key, query_array|
	    	uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{key}/cards/execute_mql.json")

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
	  
	  	# pp completed_queries

	    reduced_query = completed_queries.transpose.map! {|x| x.reduce(:+)}
		
		# pp reduced_query
	end

	scope = get_scope(constructed_queries)


	def construct_final(dates, query_results)
		query_categories = [:total_scope_query, :completed_scope_query, :actual_completed_query]
		queries_by_date = query_results.each_slice(dates.length).to_a
		header = ["Date", "Total Scope", "Completed Scope", "Actual Completed"]

		initial_arr = dates.map{|date| [date.to_s]}

		queries_arr = queries_by_date.transpose

		final_arr = initial_arr.zip(queries_arr)

		final_arr.each do |x|
			x.flatten!
		end

		final_arr.unshift(header)
		
		return final_arr
	end

	final_data = construct_final(dates, scope)

	def render_chart(arr)
	  %{
	      <div id="chart_div" style="width: 900px; height: 500px;"></div>
	      
	      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
	      <script type="text/javascript">
	        var arr = #{arr}

	        console.log(arr)

	        for (var i = 1; i<arr.length; i++){
           		console.log(arr[i][0] = arr[i][0].replace(arr[i][0], new Date(arr[i][0])))
          	}

          	console.log(arr)
	      </script>
	  }

	end

	outfile = File.open('/Users/thoughtworker/Mingle/mingle_13_4_2/vendor/plugins/consolidated_burnup_chart/test.html', 'w')
	outfile.puts('<HTML><head></head><body>')
	outtext = render_chart(final_data)
	outfile.puts(outtext)
	outfile.close

# "SELECT SELECT SUM('Story Points') AS OF '2014-02-05' WHERE type = Story and 'Carfax Initiative' = 'DBU Top 5' AND SimpleStatus = Done for a single date (ie "2014-02-05")
# for specific query category (ie :total_scope_query)
# for each project (ie "cc")
# get the projects query (ie "cc"[:total_scope_query])
# add the AS OF date (ie concat 'AS OF' statement)
# execute MQL and uri (ie make API call)
# add this result to the counter (ie get result and += to counter)
# return counter as related to date (ie "2014-02-05" => counter)

# [
# 	["Date", "Total Scope", "Completed Scope", "Actually Completed"],
# 	["2014-02-05", value1, value2, value3],
# 	["2014-02-10", value1, value2, value3],
# 	["2014-02-15", value1, value2, value3],
# 	["2014-02-20", value1, value2, value3],
# 	["2014-02-25", value1, value2, value3],
# 	["2014-02-30", value1, value2, value3],
# 	["2014-03-01", value1, value2, value3],
# ]

