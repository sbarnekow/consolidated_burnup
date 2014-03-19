require 'json'
require 'uri'
require 'net/http'
require 'time'
require 'date'

start_date = Date.parse('17-03-2014')
date_array = [start_date]

def get_dates(date_array)
  end_date = Date.parse('30-03-2014')
  new_date = date_array[-1] + 5

  if new_date <= end_date
    date_array.push(new_date)
    get_dates(date_array)
  else
    date_array.push(end_date)
    date_array.each {|x| x.to_s}
    return  date_array.sort!
  end

end


def render_chart(date_array, project_array)
  %{
      <div id="chart_div" style="width: 900px; height: 500px;"></div>
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript">
      
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);

      function drawDateFormatTable(date_array, project_array){
        var data = new google.visualization.DataTable();
        data.addColumn('date', 'Date')
        
        for (var i=0; i<project_array.length; i++){
          data.addColumn("string", project_array[i]["Title"])
        }
        
        for (var i=0; i<date_array.length; i++){
          data.addRow([date_array[i]])
        }
      }
      </script>
  }

end

def retrieve_data(date_array)
    # below is stubbed data
   
    # date = '"2014-01-10"'
    project_array = ["cc", "dvip", "bid"] #this will eventually be parameters['projects']
    future_date_array = []

    date_array.each do |date|

      query = 'SELECT SUM("Story Points") WHERE type=Story AND SimpleStatus = Done AND "Date Accepted" <= '
      whole_query = query + date.to_s

      project_array.each do |project|
        
        uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        
        #stubbed MQL
        request.form_data = {:mql => whole_query}
        
        #MQL will take a string, interpolation isnt working :( 
        response = http.request(request)   

        #creates the structure for the required dataset   
        gnar = response.body

        obj = JSON.parse(gnar).first

        puts obj
      
      end
    
    end

    puts future_date_array
    
    # get a set of data for each project, using date array
    # push that set of date to the corresponding arrays within data_array
    # for project 1 would go to [1][1], [2][1], [3][1], [4][1] 
    # project 2 would go to [1][2], [2][2], [3][2], [4][2]

    # dates and values will only be strings


end


puts get_dates(date_array)
puts retrieve_data(date_array)


