require 'date'
require 'json'
require 'uri'
require 'net/http'

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


def render_chart(render_this)
  %{
      <div id="chart_div" style="width: 900px; height: 500px;"></div>
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      var arr = #{render_this}
      function drawChart() {
        for (var i=0; i< data_array.length; i++)
          { 
            var wholeDate = data_array[i][0]
            var date 
            var year = parseInt(wholeDate.substring(0,4))
            var month = parseInt(wholeDate.substring(5,7))
            var day = parseInt(wholeDate.substring(8,10))
                
             console.log(year)
             console.log(month)
             console.log(day)
          }
        }

      </script>
  }
end

# divToWrite.appendChild(content);
# divToWrite.appendChild(spaceBreak);

 # var data = google.visualization.arrayToDataTable( #{render_this.to_json} ); 

 # var data = google.visualization.arrayToDataTable([
 #            ['Day', 'Amount'],
 #            [new Date(2014, 1, 09),  0],
 #            [new Date(2014, 1, 10),  1000],
 #            [new Date(2014, 1, 11),  1170],
 #            [new Date(2014, 1, 12),  1220],
 #            [new Date(2014, 1, 13),  1300]
 #          ]);

     # var options = {
     #      title: 'Test Chart',
     #      trendlines: { 0: {} }
     #    };

# var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
#         chart.draw(data, options);


def retrieve_data
    # # below is stubbed data
    # date = '"2014-01-10"' #this will eventually be date_array
    # project_array = ["cc", "dvip", "bid"] #this will eventually be parameters['projects']
    # query = 'SELECT project, SUM("Story Points") WHERE type=Story AND SimpleStatus = Done AND "Date Accepted" <= '
    # whole_query = query + date

    # future_date_array = []

    # project_array.each do |project|
      
    #   uri = URI.parse("http://sbarnekow:p@localhost:8080/api/v2/projects/#{project}/cards/execute_mql.json")

    #   http = Net::HTTP.new(uri.host, uri.port)
    #   request = Net::HTTP::Get.new(uri.request_uri)
      
    #   #stubbed MQL
    #   request.form_data = {:mql => whole_query}
      
    #   #MQL will take a string, interpolation isnt working :( 
    #   response = http.request(request)   

    #   #creates the structure for the required dataset   
    #   future_date_array.push(response.body.to_json)

    # end

    # puts future_date_array
    
    # get a set of data for each project, using date array
    # push that set of date to the corresponding arrays within data_array
    # for project 1 would go to [1][1], [2][1], [3][1], [4][1] 
    # project 2 would go to [1][2], [2][2], [3][2], [4][2]

    # dates and values will only be strings


    return data_array = [
            # ['Day', 'Amount'],
            ['2014-01-09',  0],
            ['2014-01-10',  1000],
            ['2014-01-11',  1170],
            ['2014-01-12',  1220],
            ['2014-01-13',  1300]
    ]
end



    # return data_array = [
    #         ['Day', 'Amount'],
    #         [DateTime.parse('2014/1/09'),  0],
    #         [DateTime.parse('2014/1/10'),  1000],
    #         [DateTime.parse('2014/1/11'),  1170],
    #         [DateTime.parse('2014/1/12'),  1220],
    #         [DateTime.parse('2014/1/13'),  1300]
    # ]

    puts get_dates(date_array)


outfile = File.open('/Users/thoughtworker/Mingle/mingle_13_4_2/vendor/plugins/consolidated_burnup_chart/test.html', 'w')
outfile.puts('<HTML><head></head><body>')
data_to_render = retrieve_data
outtext = render_chart(data_to_render)
outfile.puts(outtext)
outfile.close