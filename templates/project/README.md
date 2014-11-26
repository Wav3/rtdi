#Start the Server
    rtdi start

#Configure
To configure rtdi you need to edit `/path/to/project/lib/main.csv` and insert in it your most important hosts and services according to the following syntax:

    Tile-id,display name,objectname in icinga,objecttype,group,raw-data

###Explanation
- **Tile-id** You use the tile-id to order a object to a tile on the dashboard.  
- **Display name** This is the displayed name of the object.  
- **objectname in icinga** This is the name of the object in icinga.  
- **objecttype** This is the type of your object (host or service) - When you will display the full status of a host with its services you should write "servicehost".  
- **group** When the object is an group you should write "true" - otherwise "false".  
- **raw-data** When you will display raw-data like temperature you should write "true".  

Now you should generate a new dashboard with `rtdi generate dashboard DASHBOARD_NAME` and a new job with `rtdi generate job JOB_NAME`.  
The examples for the dashboard and the job you can find here: `/path/to/project/dashboard/rtdi_sample.erb` and `/path/to/project/jobs/rtdi_sample.rb`
