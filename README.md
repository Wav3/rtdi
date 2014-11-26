# Real Time Dashboard for Icinga (RTDI)

It's a fork from [Dashing](http://github.com/Shopify/dashing).  
**This project is maintained by [Wav3](https://github.com/Wav3/rtdi)**
**This repository is no longer being maintained - Goto Wav3's Fork [here](https://github.com/Wav3/rtdi)**


This is an awesome solution to display the most important serverstatus from [icinga](http://icinga.org) in one (or more) dashboards in realtime.  
You can access the dashboards via every browser.
We use this to display our most important serverstatus from icinga in our offices with Raspberry Pi's.
![Picture](http://blog.kroegerj.de/content/images/2014/11/Dashing.png)
This is one of our Dashboards.

##Prerequisites
- You need [check_mk](http://mathias-kettner.de/checkmk_livestatus.html) to use rtdi.
- You need a functioning icinga-installation
- icinga and this **must** be on the same system!

##Installation
1. Install the rtdi-gem on your system.  


    gem install rtdi

2. Create a new project


    rtdi new PROJECT_NAME

3. Bundle the project


    bundle install

Now you can start the program with `rtdi start`.

##Configure
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

**This project is maintained by [Wav3](https://github.com/Wav3/rtdi)**
**This repository is no longer being maintained - Goto Wav3's Fork [here](https://github.com/Wav3/rtdi)**
