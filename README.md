# MQ-Logic-Unit-of-Work
Shell and Python scripts to determine Long running Unit of work under MQ

This repository contains scripts will search under a Queue Manager for work held out against the MQ Logs past a duration of seconds. There are Python and Shell scripts. The Python script is more advanced and display more information.

There are two outputs from the script. A report and a Logging file. The detail of the Logging file is driven by the level setting in the Logger Properties file.

The script is driven by a properties file and a logger properties file

The duration is kept in the properties file. If it is missing the script will default to 20 seconds.

The Targeted Queue Manager in in the properties file. I this is missing the script will run against all Queue Managers

The script runs in SERVER mode.  This does not connect to the Queue Manager in PYTHONS default CLIENT mode. To achieve CLIENT Mode PYTHON must be recompiled as a SERVER or the client connect to the QMGR must be implemented. There is a connect_Queue_manager.py method included in this library that presents what you need for CLIENT mode. The additional properties need to be added to the config.properties file.

TESTING:
I tested this using RFHUTILC in the IH03 support pack:
     1 - Read a Text file into RFHUTIL for data.
     2 - Click MQMD tab and set Group to FIRST and Persistent to YES
     3 - Fill in QMGR name with 'Channel/TCP/ip(port)' of queue manager
     4 - click load queues (Log window should show success.
     5 - select queue and write to queue.
     6 - wait appropriate time (20 seconds by default)
     7 - run program on MQ server.
     6 - look at report, prefixed with servers name (sample in this repository running on server named 'fibbing'
     7 - when finished, write last group message to queue ending LUW

REPORT:

Long Running Task Report for MQ

Channel Name = SYSTEM.ADMIN.SVRCONN

     Number of seconds UOW is out = 58832.09

     Start Date of UOW = 2023-04-03

     Start Time of UOW = 13.21.32

     Conn ID = AMQCBOBBEE      \xfdb\x02d\x01>\x8a!

     Application TAG = port Packs\IH03\rfhutilc.exe

     Beginning Log Extent = S0000000.LOG

     Application UID = mqm

     Process ID = 17885

     Object Names = BOBBEE

               MQPUT Count = 45

               MQPUT Non-Persistent Count = 19

               MQPUT Persistent Count =  26

               MQPUT1 Non-Persistent Count =  0

               MQPUT1 Persistent Count =  0

               Current Queue Depth =  1

               Open Input Count =  0

               Open Output Count =  1
