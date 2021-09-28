# **DCDoctor**

                              -/osyhhhhyys+:.                              
                           /yhhhhhhhhhhhhhhhy/.                           
                          :yhhhhhhhhhhhhhhhhhhhh/                          
                       ./shhhhhhhhhhhhhhhhhhhhhhhs                        
                      :yhhhhhhhhhhhhhhhhhhhhhhhhhhy+                      
                     yhhhh+ohhhhhhhhhhhhhhhs+-/hhhh+                      
                     :hhhh:  .+shhyyyyssoo+//   +hhhy                      
                     /hhh+     .-/+ooooooo+/   .hhhy                      
                     -hhh:            `        hhho                      
                     yhh+                       hhh:                      
                    ohhhy                      .hhhs+                     
                    .hhhhh-                     /hhhhy                     
                     :shhhs                    yhhho-                     
                      -/hh/                   +hh/-                       
                         /hh-                 /hh:                         
                          +hh:              /hh:                          
                           :yh+           .ohy-                           
                            .ohy/.      -+hh+                            
                              -ohhso+/+oyhy+.                              
                                -/oooo+/-                                 
                           `                 `                           
                    .-/+syho                 shyo+/-.                    
               -/oshhhhhhhhh-     /o:     /hhhhhhhhys+/-               
             -oyhhhhys+/:.shhy    shhh+    .hhho.:/osyhhhhyo-             
           shhhs+yh/     -hhho    /hhh-   shhy    -hh+shhho           
           ohhh- +ho      /hhh/   shhh+   ohhh-      oho :hhh/           
          -hhh/   -hy      +hhh: hhhhy  +hhh:  .-::/hh.   ohhh.          
          ohhy   yh:      ohhh::hhhhh-+hhh/:syysosyho-  .hhh+          
         hhh+     :hy       +hhhyhhhhhyhhh:+hs-` `:yh/  shhy         
         :hhh.      oho        :yhhhhhhhhhs-+hs       -hh :hhh-         
         ohhy       yh/        .ohhhhhhh+`ohs        .hh hhh/         
        yhho        .yh+/:.      :yhhhs- oho         +ho   shhs         
        .hhh:         ohhhhy.      /+:  ohs         hh-   +hhh        
        /hhh.         ohhhhh-            -hh          /hs    -hhh-        
        +hhh          /os+-             :hh:        yh:    .hhh/        
        yhhs                              :oy+     `+hs      hhho        
       yhho                                      :ssyhs      shhs        
       .hhh/                                      -::-       ohhy       
       :hhhyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyhhh.       
       +hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh:  

This is designed to be a script which is run automatically as a scheduled task on Domain Controllers to check their integrity and log any detected issues.
The script will always create a log, however if it finds any errors or issues - it will also create an error log and E-Mail to the user explaining the problem.

## Installation Guide:

1) Clone the repository to a location on your Domain Controller. For the purpose of this guide, it will be ***C:\DCDoctor***.
2) The script will by default, log everything to the ***C:\DCDoctor*** directory. This can be changed by modifying the ***$logPath*** variable near the top of the script.
   If the directory does not exist, the script will automatically create it when first run.
3) Open the script in a text editor such as Notepad++, Visual Studio Code or PowerShell ISE.
4) To enable E-Mail reporting, locate and set the following variables (near the bottom of the script in the ***#START E-MAIL*** section):
*  ***$to*** = *"username@example.com"*
*  ***$from*** = *"noreply@example.com"*
*  ***$smtpServer*** = *"smtp.server.com"*
*  ***$smtpServerPort*** = *587*
5) Save the script.
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
