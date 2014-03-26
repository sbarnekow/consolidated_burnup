require 'json'
require 'uri'
require 'net/http'
require 'time'
require 'date'

def format_parameters(params)
  project_query_hash = {}
 
  params['series'].each do |project|
    project_query_hash << { project['project-name'] => {
      :total_scope_query => project['scope-query'], 
      :completed_scope_query => project['completion-scope-query'], 
      :actual_scope_query => project['actual-scope-query']
      }
    }
  end

  return project_query_hash
end


start_date = Date.parse('05-02-2014')
date_array = [start_date]

def get_dates(date_array)
  end_date = Date.parse('20-03-2014')
  new_date = date_array[-1] + 5

  if new_date <= end_date
    date_array.push(new_date)
    get_dates(date_array)
  else
    date_array.push(end_date)
    date_array.each {|x| x.to_s}
    # return  date_array.sort!
  end
  return date_array.map {|x| x.to_s}

end

def get_header_row
  project_array = ["cc", "dvip", "bid"]
  
  header = ["Date"]

  project_array.each do |project|
    whole_query = "SELECT Project"
    uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    
    request.form_data = {:mql => whole_query}
    response = http.request(request)    
    body = response.body

    obj = JSON.parse(body)
    header << obj.first["Project"]
  end

  return header
end

def scope(series_hash, date_array)
  # SELECT sum('estimate') WHERE type = story and intiative = hawk + AS OF date
    project_array = ["cc", "dvip", "bid"]
    project_date_constructor = {}

    date_array.each do |date|
      consolidated_points = 0
      project_date_constructor[date] ||= {}

      whole_query = "SELECT SUM('Story Points') AS OF '#{date.to_s}' WHERE type=Story"
        
        project_array.each do |project|
          uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)
          
          request.form_data = {:mql => whole_query}
          response = http.request(request)     
          body = response.body

          obj = JSON.parse(body).first
  
          consolidated_points += obj["Sum Story Points"].to_i

          project_date_constructor[date] = consolidated_points
        end
    end

    return project_date_constructor
end

def completed_scope(series_hash, date_array)
  project_array = ["cc", "dvip", "bid"]
    project_date_constructor = {}

    date_array.each do |date|
      consolidated_points = 0
      project_date_constructor[date] ||= {}

      whole_query = "SELECT SUM('Story Points') AS OF '#{date.to_s}' WHERE type=Story AND SimpleStatus = 'In Progress'"
        
        project_array.each do |project|
          uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)
          
          request.form_data = {:mql => whole_query}
          response = http.request(request)     
          body = response.body

          obj = JSON.parse(body).first
  
          consolidated_points += obj["Sum Story Points"].to_i

          project_date_constructor[date] = consolidated_points
        end
    end

    return project_date_constructor
end

def actual_completed(series_hash, date_array)
  project_array = ["cc", "dvip", "bid"]
    project_date_constructor = {}

    date_array.each do |date|
      consolidated_points = 0
      project_date_constructor[date] ||= {}

      whole_query = "SELECT SUM('Story Points') AS OF '#{date.to_s}' WHERE type=Story AND SimpleStatus = Done"
        
        project_array.each do |project|
          uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)
          
          request.form_data = {:mql => whole_query}
          response = http.request(request)     
          body = response.body

          obj = JSON.parse(body).first
  
          consolidated_points += obj["Sum Story Points"].to_i

          project_date_constructor[date] = consolidated_points
        end
    end

    return project_date_constructor
end


def construct_final_array(header_row, data)
  header = ["Date", "Scope", "Completed Scope", "Actual Scope"]
  first_row = ["2014-02-01", 0, 0, 0]
  keys = data.first.keys
  new_arrs = keys.map {|k| [k] + data.map {|h| h[k]}}
  new_arrs.unshift(header, first_row)
  return new_arrs
end


def render_chart(arr)
  %{
    <div id="chart_div" style="width: 900px; height: 500px;"></div>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">

      var rubyData = #{arr};
    

      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable( rubyData );

        var options = {
          title: 'Consolidated Burn Up',
          trendlines: { 0: {} }
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  }

end

header = get_header_row
dates = get_dates(date_array)
scope = scope(header, dates)
completed_scope = completed_scope(header, dates)
actual = actual_completed(header, dates)

alldata = scope, completed_scope, actual
final_array = construct_final_array(header, alldata)

render_chart(final_array)

# def retrieve_data(query, date_array, project_array)    
#   # we want three things: total scope, completed scope, total of query

#     project_date_constructor = {}

#     date_array.each do |date|
      
#       project_date_constructor[date] ||= {}

#       whole_query = "SELECT SUM('Story Points') WHERE type=Story AND SimpleStatus = Done AND 'Date Accepted' <= '#{date.to_s}'"

#         project_array.each do |project|
          
#           uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

#           http = Net::HTTP.new(uri.host, uri.port)
#           request = Net::HTTP::Get.new(uri.request_uri)
          
#           #stubbed MQL
#           request.form_data = {:mql => whole_query}
          
#           #MQL will take a string, interpolation isnt working :( 
#           response = http.request(request)   

#           #creates the structure for the required dataset   
#           body = response.body

#           obj = JSON.parse(body).first
        
#           project_date_constructor[date][project] = obj["Sum Story Points"].to_i
#         end

#     end
    
#     return project_date_constructor
# end

# def construct_final_array(header_row, data)
#   final_array = []
#   final_array << header_row
#   projects =  ["cc", "dvip", "bid"]

#   data.each do |date, project_values|
#     # p project_values
#     final_array << [date] + projects.map {|p| project_values[p]}
#   end
#   return final_array
# end










# def render_chart(header, data)
#   %{
#     <div id="chart_div" style="width: 900px; height: 500px;"></div>
#     <script type="text/javascript" src="https://www.google.com/jsapi"></script>
#     <script type="text/javascript">

#       var rubyData = #{construct_final_array(header, data)};
    

#       google.load("visualization", "1", {packages:["corechart"]});
#       google.setOnLoadCallback(drawChart);
#       function drawChart() {
#         var data = google.visualization.arrayToDataTable( rubyData );

#         var options = {
#           title: 'Consolidated Burn Up',
#           trendlines: { 0: {} }
#         };

#         var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
#         chart.draw(data, options);
#       }
#     </script>
#   }

# end

# def retrieve_data(query, date_array, project_array)    
#   # we want three things: total scope, completed scope, total of query

#     project_date_constructor = {}

#     date_array.each do |date|
      
#       project_date_constructor[date] ||= {}

#       whole_query = "SELECT SUM('Story Points') WHERE type=Story AND SimpleStatus = Done AND 'Date Accepted' <= '#{date.to_s}'"

#         project_array.each do |project|
          
#           uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

#           http = Net::HTTP.new(uri.host, uri.port)
#           request = Net::HTTP::Get.new(uri.request_uri)
          
#           #stubbed MQL
#           request.form_data = {:mql => whole_query}
          
#           #MQL will take a string, interpolation isnt working :( 
#           response = http.request(request)   

#           #creates the structure for the required dataset   
#           body = response.body

#           obj = JSON.parse(body).first
        
#           project_date_constructor[date][project] = obj["Sum Story Points"].to_i
#         end

#     end
    
#     return project_date_constructor
# end

# def construct_final_array(header_row, data)
#   final_array = []
#   final_array << header_row
#   projects =  ["cc", "dvip", "bid"]

#   data.each do |date, project_values|
#     # p project_values
#     final_array << [date] + projects.map {|p| project_values[p]}
#   end
#   return final_array
# end

# header = get_header_row

# dates = get_dates(date_array)
# # projects =  ["cc", "dvip", "bid"]
# projects =  ["cc"]

# retrieve_scope(dates, projects)
# retrieve_completed_scope(dates, projects)
# retrieve_actual_completed(dates, projects)

# data = retrieve_data(projects, dates)
# p construct_final_array(header, data)


outfile = File.open('/Users/thoughtworker/Mingle/mingle_13_4_2/vendor/plugins/consolidated_burnup_chart/test.html', 'w')
outfile.puts('<HTML><head></head><body>')
outtext = render_chart(final_array)
outfile.puts(outtext)
outfile.close

