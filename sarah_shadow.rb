require 'json'
require 'uri'
require 'net/http'
require 'time'
require 'date'

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
    return  date_array.sort!
  end
  return date_array.map {|x| x.to_s}
end


def render_chart(header, data)
  %{
    <div id="chart_div" style="width: 900px; height: 500px;"></div>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable(
            #{construct_final_array(header, data)}
        );

        var options = {
          title: 'Consolidated Burn Down'
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  }

end

def get_header_row
  #stubbed data
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

def retrieve_data(project_array, date_array)    
    project_date_constructor = {}

    date_array.each do |date|
      
      project_date_constructor[date] ||= {}

      whole_query = "SELECT SUM('Story Points') WHERE type=Story AND SimpleStatus = Done AND 'Date Accepted' <= '#{date.to_s}'"
      # whole_query = query + date.to_s

      # p whole_query

        project_array.each do |project|
          
          uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)
          
          #stubbed MQL
          request.form_data = {:mql => whole_query}
          
          #MQL will take a string, interpolation isnt working :( 
          response = http.request(request)   

          #creates the structure for the required dataset   
          body = response.body

          obj = JSON.parse(body).first
        
          project_date_constructor[date][project] = obj["Sum Story Points"].to_i
        end

    end
    
    return project_date_constructor
end

def construct_final_array(header_row, data)
  final_array = []
  final_array << header_row
  projects =  ["cc", "dvip", "bid"]

  data.each do |date, project_values|
    # p project_values
    final_array << [date] + projects.map {|p| project_values[p]}
  end
  return final_array
end

header = get_header_row
dates = get_dates(date_array)

projects =  ["cc", "dvip", "bid"]

data = retrieve_data(projects, dates)
p construct_final_array(header, data)


outfile = File.open('/Users/thoughtworker/Mingle/mingle_13_4_2/vendor/plugins/consolidated_burnup_chart/test.html', 'w')
outfile.puts('<HTML><head></head><body>')
data_to_render = retrieve_data(projects, dates)
outtext = render_chart(header, data)
outfile.puts(outtext)
outfile.close

