# **DCDoctor**

           Paul Rowland - https://github.com/pauljrowland/DCDoctor

                              -/osyhhhhyys+:.
                            '/yhhhhhhhhhhhhhhhy/.
                           :yhhhhhhhhhhhhhhhhhhhh/
                        ./shhhhhhhhhhhhhhhhhhhhhhhs
                       :yhhhhhhhhhhhhhhhhhhhhhhhhhhy+
                      'yhhhh+ohhhhhhhhhhhhhhhs+-/hhhh+
                      :hhhh:  .+shhyyyyssoo+//   +hhhy
                      /hhh+     '.-/+ooooooo+/   .hhhy
                      -hhh:            '''        hhho
                      'yhh+                       hhh:
                     'ohhhy                      .hhhs+
                     .hhhhh-                     /hhhhy
                      :shhhs                    'yhhho-
                       '-/hh/                   +hh/-
                          /hh-                 /hh:
                           +hh:              '/hh:
                            :yh+'           .ohy-
                             .ohy/.      '-+hh+
                               -ohhso+/+oyhy+.
                                 '-/oooo+/-
                            --                 --
                     '.-/+syho                 shyo+/-.
                '-/oshhhhhhhhh-     '/o:'     /hhhhhhhhys+/-
              -oyhhhhys+/:.shhy'    shhh+    .hhho.:/osyhhhhyo-
            'shhhs+yh/     -hhho    /hhh-   'shhy'    '-hh+shhho
            ohhh-' +ho      /hhh/   shhh+   ohhh-      oho ':hhh/
           -hhh/   -hy'      +hhh: 'hhhhy  +hhh:  .-::/hh.   ohhh.
           ohhy'   'yh:      'ohhh::hhhhh-+hhh/':syysosyho-  .hhh+
          'hhh+     :hy'       +hhhyhhhhhyhhh:'+hs-'' '':yh/  shhy
          :hhh.      oho        :yhhhhhhhhhs-'+hs'       -hh' :hhh-
          ohhy       'yh/        .ohhhhhhh+''ohs'        .hh' 'hhh/
         'yhho        .yh+/:.      :yhhhs- 'oho'         +ho   shhs
         .hhh:         ohhhhy.      '/+:'  ohs'         'hh-   +hhh
         /hhh.         ohhhhh-            -hh'          /hs    -hhh-
         +hhh          '/os+-             :hh:'        'yh:    .hhh/
         yhhs                              :oy+     '''+hs      hhho
        'yhho                                      :ssyhs'      shhs
        .hhh/                                      '-::-'       ohhy
        :hhhyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyhhh.
        +hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh: 

This is designed to be a script which is run automatically as a scheduled task on Domain Controllers to check their integrity and log any detected issues.
The script will always create a log, however if it finds any errors or issues - it will also create an error log and E-Mail to the user explaining the problem.

There is a ***DCDoctor_Settings.conf*** which is placed with the ***DCDoctor.ps1***. Parameters in this fie will over-write the defaults specified in the script.
You do not need this .conf file to be present, however any changes you make within the main script will be overwritten when you update.

## Installation Guide:

1) Clone the repository to a location on your Domain Controller. For the purpose of this guide, it will be ***C:\DCDoctor***.
2) The script will by default, log everything to the ***C:\DCDoctor\Logs*** directory. This can be changed by modifying the ***installPath*** parameter in the
   ***DCDoctor_Settings.conf*** file. If the directory does not exist, the script will automatically create it when first run.
3) To bypass servers, open the ***DCDoctor_Settings.conf*** file, locate and set to look like the following:
*  excludedServers=SERVER1,SERVER2,SERVER3
4) To enable E-Mail reporting, open the ***DCDoctor_Settings.conf*** file, locate and set to look like the following:
*  sendMailReport=YES
*  to=username@example.com
*  from=noreply@example.com
*  smtpServer=smtp.server.com
*  smtpServerPort=587
5) To disable E-Mail reporting (default), set ***sendMailReport*** to ***NO*** or leave blank (i.e. ***sendMailReport=No*** or ***sendMailReport=***)
6) Create a new Basic Scheduled Task to run at your required interval (in this case, daily at 1am.):
*  ***Name***: *DC Doctor*
*  ***When***: *Daily*
*  ***Time***: *01:00:00*
*  ***Recur***: *Every 1 Days*
*  ***Action***: *Start a Program*
*  ***Program/Script***: *powershell.exe*
*  ***Add arguments***: *-File 'C:\DCDoctor\DCDoctor.ps1' -ExecutionPolicy -Bypass*
*  ***Open additional Poroperties***
*  ***Change the user to "SYSTEM"***
*  ***Select to run whether a user is logged on or not***
*  ***Close the task, right click and carry out a test run***
7) You should see a text file named ***DCDcotor_Results.txt*** file with an output of the test results.
8) If there are any errors, there will be a ***DCDoctor_Error.txt*** explaining any issues (and an E-Mail containing a copy of this file)
