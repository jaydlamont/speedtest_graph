#!/bin/bash

# Execute the speedtest
/home/jay/speedtest-cli-extras/bin/speedtest-csv | 

# Modify results to change dashes to semicolons
sed 's/\-/;/g' |

# Modify results to separate the time from the date with a semicolon
sed 's/ /;/' |

# Remove Mbit/s from speed to show only the numerical speed and write to speedtest.csv
sed s/" Mbit\/s"//g >> /home/jay/speedtest.csv

# AWK to display only date (in YYYY,M,DD format), download speed and upload speed plus formatting for Google Charts
RESULT=$(awk -F';' '{print "[new Date("$1", "$2-1", "$3"), "$13", "$14"], "}' /home/jay/speedtest.csv)

# Write date to variable with timezone and year removed
DATE=$(date | awk -F ' ' '{print $1" "$2" "$3" "$4}')

# AWK to display IP Address from last line of speedtest.csv
CURRENT_IP=$(awk -F';' 'END {print $9}' /home/jay/speedtest.csv)

# AWK to display last speed test provider
PROVIDER=$(awk -F';' 'END {print $10}' /home/jay/speedtest.csv | awk -F '(' '{print $1}')

# AWK to display last speed test location
LOCATION=$(awk -F';' 'END {print $10}' /home/jay/speedtest.csv | awk -F '(' '{print $2}' | sed 's/)//')

# AWK to display estimated distance
DISTANCE=$(awk -F';' 'END {print $11}' /home/jay/speedtest.csv)

# Get Raspberry Pi uptime and display only days
UPTIME=$(uptime | sed 's/,//'| awk -F ' ' '{print $3" "$4}')

# Remove current speed_output.html to prep for new version
rm /var/www/html/speed_output.html 2> /dev/null

# Write the HTML to speed_output.html
cat << EOT >> /var/www/html/speed_output.html
<html>

<head>



  <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

  <script type="text/javascript">



    google.charts.load('current', {'packages':['corechart']});

    google.charts.setOnLoadCallback(drawChart);



      function drawChart() {



        var data = new google.visualization.DataTable();

        data.addColumn('date', 'Time of Day');

        data.addColumn('number', 'Download');

	data.addColumn('number', 'Upload');



        data.addRows([
EOT

# Add the results of the speed tests generated from the RESULTS AWK to be used in the chart
echo $RESULT >> /var/www/html/speed_output.html

# Resume writing HTML
cat << EOT >> /var/www/html/speed_output.html

        ]);





        var options = {

          title: 'Bell Fibe Daily Speed Test',

          width: 900,

          height: 500,

          hAxis: {

            format: 'M/d/yy',

            gridlines: {count: 15}

          },

          vAxis: {

            gridlines: {color: 'none'},

            minValue: 0

          }

        };



        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));



        chart.draw(data, options);



        var button = document.getElementById('change');



        button.onclick = function () {



          // If the format option matches, change it to the new option,

          // if not, reset it to the original format.

          options.hAxis.format === 'M/d/yy' ?

          options.hAxis.format = 'MMM dd, yyyy' :

          options.hAxis.format = 'M/d/yy';



          chart.draw(data, options);

        };

      }

</script>

</head>

<body>

	<div id="chart_div" style="width: 900px; height: 500px"></div>
EOT

# Add other stats (generated from AWK or commands) to the HTML
echo "<b>Last Generated: </b>" $DATE >> /var/www/html/speed_output.html
echo "<br><br><b><u>Speed Test Stats</b></u>" >> /var/www/html/speed_output.html  
echo "<br><b>Current IP Address: </b>"$CURRENT_IP >> /var/www/html/speed_output.html
echo "<br><b>Last Test Provider: </b>"$PROVIDER >> /var/www/html/speed_output.html
echo "<br><b>Test Provider Location: </b>"$LOCATION >> /var/www/html/speed_output.html
echo "<br><b>Estimated Distance: </b>"$DISTANCE >> /var/www/html/speed_output.html
echo "<br><br><b><u>Raspberry Pi Stats</b></u>" >> /var/www/html/speed_output.html
echo "<br><b>System Uptime: </b>" $UPTIME >> /var/www/html/speed_output.html

cat << EOT >> /var/www/html/speed_output.html

</body>

</html>

EOT
