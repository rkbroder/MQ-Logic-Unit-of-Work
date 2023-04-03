# MQ-Logic-Unit-of-Work
Shell and Python scripts to determine Long running Unit of work under MQ

This repository contains scripts will search under a Queue Manager for work held out against the MQ Logs past a duration of seconds. There are Python and Shell scripts. The Python script is more advanced and display more information.

There are two outputs from the script. A report and a Logging file. The detail of the Logging file is driven by the level setting in the Logger Properties file.

The script is driven by a properties file and a logger properties file

The duration is kept in the properties file. If it is missing the script will default to 20 seconds.

The Targeted Queue Manager in in the properties file. I this is missing the script will run against all Queue Managers

The script runs in SERVER mode.  This does not connect to the Queue Manager in PYTHONS default CLIENT mode. To achieve this PYTHON must be recompiled as a SERVER or the client connect to the QMGR must be implemented. There is a connect_Queue_manager.py method included in this library that present what you need for CLIENT mode.
