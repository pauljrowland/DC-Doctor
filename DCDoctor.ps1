########################
#####
#####   DCDoctor
#####
#####   Author:              Paul Rowland
#####   Created:             12/07/2021
#####   GitHub URL:          https://github.com/pauljrowland/DCDoctor
#####   ChangeLog:           https://github.com/pauljrowland/DCDoctor/commits/main/DCDoctor.ps1
#####   License:             GNU General Public License v3.0
#####   License Agreement:   https://github.com/pauljrowland/DCDoctor/blob/main/LICENSE
#####
#####   Version:             3.3
#####   Modified Date:       18/08/2022
#####
########################

##-START-## - IMPORT CONFIGURATION

$scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent # Where is the script running from?

if (!(Test-Path -Path "$scriptRoot\DCDoctor_settings.conf")) { # If the config file doesn't exist - create it using the default file.

    if (!(Test-Path -Path "$scriptRoot\DCDoctor_settings.conf.defaults")) { # Firstly, if the defaults file is missing - get a copy from GitHub..

        $defaults = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/pauljrowland/DCDoctor/main/DCDoctor_Settings.conf.defaults" -ErrorAction SilentlyContinue)

        Out-File -FilePath "$scriptRoot\DCDoctor_settings.conf" -InputObject $defaults.Content -ErrorAction SilentlyContinue # Create the config file.
    }

    else { # It does exist, so just copy the local version.

        Copy-Item -Path "$scriptRoot\DCDoctor_settings.conf.defaults" -Destination "$scriptRoot\DCDoctor_settings.conf"

    }

}

Get-Content "$scriptRoot\DCDoctor_settings.conf" | Foreach-Object { # Now the content file exists, import contents.
    $var = $_.Split('=') # Split the line at the equals '=' sign into an array.
    Set-Variable -Name $var[0] -Value $var[1] -ErrorAction SilentlyContinue # Create a variable using the left of the '=' as the name and right of the '=' as the value.
    
}

Clear-Host

##-END-## - Importing configuration

##-START-## - SCRIPT LOGGING SECTION - Function to output logs to screen & files. Written as a function to avoid repeading code.

# Import Write-DCTestLog Function
. "$scriptRoot\SharedFunctions\Write-DCTestLog\Write-DCTestLog.ps1"

if (!(Test-Path -Path "$scriptRoot\Logs" -ErrorAction SilentlyContinue)) { # The log directory is missing.
    
    New-Item -ItemType Directory "$scriptRoot\Logs" # Create log directory.

}

$LogFile = "$scriptRoot\Logs\DCDoctor_Results.txt" # Location of the log file which is always written.
$ErrorLogFile = "$scriptRoot\Logs\DCDoctor_Error.txt" # Location of the error log file (if required).
$eMailErrorLogFile = "$scriptRoot\Logs\DCDoctor_E-Mail-Error.txt" # Location of the error log file (if required).

# Remove log files to ensure clean sweep of script
Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $ErrorLogFile -ErrorAction SilentlyContinue
Remove-Item -Path $eMailErrorLogFile -ErrorAction SilentlyContinue

##-START-## - BANNER - Display banner at the top of the PowerShell session and log file.

$date = (Get-Date -Format "dd/MM/yyy HH:mm:ss")
Write-Host @"
    Starting Script... $date
    
"@

$logo = @"

                          DCDoctor Diagnostic Report
                         Generated $date

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

"@

Write-DCTestLog -logText $logo -plain # Put the above logo on screen and in to the log files.

$DNSName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

Write-DCTestLog -logText "DCDoctor Health Report for $DNSName" -plain # Put the PC details and date etc. into the log and on screen.

Start-Sleep -Seconds 5 # Sleep for 5 seconds

##-END-## -  BANNER

##-START-## - EXCLUSION CHECK (Un-comment all lines in the EXCLUSION CHECK section if Required by removing the <# & #>)
#             Check for excluded servers in the list to prevent those with known / unfixable errors from constantly sending E-Mails.

$serverName = $env:computerName
$counter = 0
foreach ($excludedServer in $excludedServers) { # Loop through all excluded servers
    $counter++
    Write-Progress -Activity 'DCDoctor Domain Controller Checks - Checking: Excluded Servers...' -CurrentOperation $excludedServer -PercentComplete (($counter / $excludedServers.count) * 100)

    if ($excludedServer -like $serverName) { # If the server is on the list - end the script
        Write-DCTestLog -logText "This machine is present on the excluded server list, ending test..." -info
        Write-DCTestLog -logText "Ended test on $date as this was not required!" -plain
        exit
    }

}

##-END-## -  EXCLUSION CHECK

##-START-## - DC Check - Check to see whether the machine is indeed a domain controller
         
Write-DCTestLog -logText "Checking whether this machine is indeed an Active Directory Domain Controller..." -info

# Get the return code of the domain role
$domainRole = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty DomainRole

if (!($domainRole -match '4|5')) { # If the domain role doesn't match '4' (PDC) or '5' (BDC) - end the script

    Write-DCTestLog -logText "This machine is not an Active Directory domain controller, ending test..." -info

    # Complete and end script
    $date = (Get-Date -Format "dd/MM/yyy HH:mm:ss")
    Write-DCTestLog -logText "Completed test on $date" -plain
    exit

}

else { # The role does match so continue processing the script
    Write-DCTestLog -logText "This machine is an Active Directory domain controller" -pass
}

# As this script should only be run on the PDC Emulator - we need to work out what this server is

Write-DCTestLog -logText "Checking PDC Emulator FMSO Role Holder..." -info

$PDCEmulator = (Get-ADForest | Select-Object -ExpandProperty RootDomain | Get-ADDomain | Select-Object -Property PDCEmulator)

$PDCEmulator = $PDCEmulator.PDCEmulator

Write-DCTestLog -logText "The PDC Emulator has been determined to be $PDCEmulator" -info

# Testing connectivity to the PDC Emulator

if (Test-Connection -ComputerName $PDCEmulator -ErrorAction SilentlyContinue) {

    Write-DCTestLog -logText "The PDC Emulator $PDCEmulator is available" -pass

    if (!($PDCEmulator -eq $DNSName)) {

        Write-DCTestLog -logText "This machine is not the PDC Emulator so the test will not run." -info
        Write-DCTestLog -logText "Please check the results on $PDCEmulator for more information." -info

        # Complete and end script
        $date = (Get-Date -Format "dd/MM/yyy HH:mm:ss")
        Write-DCTestLog -logText "Completed test on $date" -plain
        exit
    }

}

else {

    Write-DCTestLog -logText "PDC Emulator $PDCEmulator is NOT available" -fail

    # Complete and end script
    $date = (Get-Date -Format "dd/MM/yyy HH:mm:ss")
    Write-DCTestLog -logText "Completed test on $date" -plain
    exit
}

# We have now established this is the PDC Emulator, so the test will continue.

# Now we need to get a list of domain controllers in the domain...
$domainControllers = (Get-ADDomainController -Filter "isGlobalCatalog -eq `$true")

##-END-## -  DC CHECK

##-START-## - SERVICE CHECK MODULE - Function for checking services

function checkServices {

Write-Host @"

    Performing Active-Directory critical service checks...

"@

    # List of Active Directory-Related Services to Check
    $Services = "Active Directory Domain Services","Kerberos Key Distribution Center","Intersite Messaging","DHCP Server","DNS Server" # List services to check

    $counter = 0
    ForEach ($Service in $Services) { # Loop through each service
        $counter++
        Write-Progress -Activity 'DCDoctor Domain Controller Checks - Checking: Service...' -CurrentOperation $Service -PercentComplete (($counter / $Services.count) * 100)

        Write-DCTestLog -logText "Checking $Service Service on $env:COMPUTERNAME" -info

        if (Get-Service -DisplayName $Service -ErrorAction SilentlyContinue) { # If the service is installed - continue to check status

            # Get the status of the service
            $ServiceStatus = (Get-Service -DisplayName $Service | Select-Object -ExpandProperty Status)

            # Get the start mode of the service
            $ServiceStartType = Get-WmiObject -Class Win32_Service -Property StartMode -Filter "DisplayName='$Service'"
            $ServiceStartType = $ServiceStartType.StartMode

            if ($ServiceStatus -ne "Running") { # If the service isn't running, find out why and try to rectify it
            
                if ($ServiceStartType -ne "Disabled") { # If the service isn't disabled, try to start it

                    Write-DCTestLog -logText "$Service is not running on $env:COMPUTERNAME:, trying to start..." -warn

                    # Try to start the service
                    Start-Service -DisplayName $Service

                    # Pause for 20 seconds to give the service time to start
                    Start-Sleep -Seconds 20

                    # Get the status of the service
                    $ServiceStatus = (Get-Service -DisplayName $Service | Select-Object -ExpandProperty Status)

                    if ($ServiceStatus -ne "Running") { # If the service still isn't running - log an error
                        Write-DCTestLog -logText "$Service failed to start and is currently $ServiceStatus with a Startup Type as $ServiceStartType on $env:COMPUTERNAME" -fail
                    }

                    else { # The service has now started - don't log an error
                        Write-DCTestLog -logText "$Service has now started with a Startup Type as $ServiceStartType on $env:COMPUTERNAME" -pass
                    }

                }

                else { # The service isn't running as it is disabled - don't log an error
                    Write-DCTestLog -logText "$Service is currently disabled on $env:COMPUTERNAME" -info
                }

            }

            else  { # The service must be running - don't log an error
                Write-DCTestLog -logText "$Service is running with a Startup Type as $ServiceStartType on $env:COMPUTERNAME" -pass
            }

        }

        else { # The service isn't installed on the server (i.e. 'DHCP Server') - don't log an error
            Write-DCTestLog -logText "$Service is not installed as a service on $env:COMPUTERNAME" -info
        }

    }

    #

}

##-END-## -  SERVICE CHECK MODULE

##-START-## - ACTIVE DIRECTORY CHECK MODULE - Checking AD Communication etc.

function checkDCConnectivity{

Write-Host @"

    Performing Active-Directory FSMO connectivity checks...

"@

    if ($PSVersionTable.PSVersion.Major -gt 2) { # Only run if PowerShell is running a verion greater than 2 as some CMDLETS are not compatible with older versions

        # Check whether the ActiveDirectory PowerShell module is installed to prevent the script failing on older DCs

        Write-DCTestLog -logText "Importing Acive Directory Module on $env:COMPUTERNAME..." -info

        if (Get-Module -ListAvailable -Name ActiveDirectory -ErrorAction SilentlyContinue) { # If the AD module is present, import it and set the $ADModuleInstalled variable to $true to ensure the function continues to run

            # Set the variable
            $ADModuleInstalled = $true

            # Import the ActiveDirectory Module
            Import-Module ActiveDirectory
            
            Write-DCTestLog -logText "Active Directory Module has been imported on $env:COMPUTERNAME" -pass

        } 

        else { # If the AD module is NOT present, don't try to import it and set $ADModuleInstalled variable to $false to end the function

            # Set the variable
            $ADModuleInstalled = $false

            Write-DCTestLog -logText "Active Directory Module is not available so some tests may not run on $env:COMPUTERNAME!" -warn

        }

        ##-END-## -  AD MODULE CHECK

        if ($ADModuleInstalled) { # If the AD module was previously detected - continue the check
        
            # Create an array of FSMO roles and who the masters are.
            $FSMOHolders = @(("InfrastructureMaster", (Get-ADDomain | Select-Object -ExpandProperty InfrastructureMaster)),
            ("RIDMaster",(Get-ADDomain | Select-Object -ExpandProperty RIDMaster)),
            ("PDCEmulator",(Get-ADDomain | Select-Object -ExpandProperty PDCEmulator)),
            ("DomainNamingMaster",(Get-ADForest | Select-Object -ExpandProperty DomainNamingMaster)),
            ("SchemaMaster",(Get-ADForest | Select-Object -ExpandProperty SchemaMaster)))

            $counter = 0
            foreach ($FSMOHolder in $FSMOHolders) { # Check every FSMO role holder for connectivity. (If one DC holds more then one role, the test will repeat against the same target)

                # Split the role and holder into two variables
                $FSMORole,$FSMOHolder = $FSMOHolder.split(' ')

                $counter++
                Write-Progress -Activity 'DCDoctor Domain Controller Checks - Checking: FSMO Holder...' -CurrentOperation $FSMOHolder -PercentComplete (($counter / $FSMOHolders.count) * 100)
    
                Write-DCTestLog -logText "Checking $FSMORole - $FSMOHolder from $env:COMPUTERNAME" -info

                if (Test-Connection $FSMOHolder -Count 2 -ErrorAction SilentlyContinue) { # Connectivity was a success - don't log an error
                    Write-DCTestLog -logText "The $FSMORole $FSMOHolder is available from $env:COMPUTERNAME" -pass
                }

                else { # Failed to connect - log an error
                    Write-DCTestLog -logText "The $FSMORole $FSMOHolder is NOT available from $env:COMPUTERNAME!" -fail
                }

            }

Write-Host @"

Performing Domain Controller connectivity and SYSVOL/NETLOGON share checks...

"@

            $counter = 0
            foreach ($DomainController in $DomainControllers) { # Loop through every domain controller
                $counter++
                Write-Progress -Activity 'DCDoctor Domain Controller Checks - Checking: Domain Controller Connectivity...' -Status "Domain Controller (Domain Controller $($counter) of $($DomainControllers.count)" -CurrentOperation $DomainController -PercentComplete (($counter / $DomainControllers.count) * 100)
                Write-DCTestLog -logText "Checking connection to domain controller $DomainController from $env:COMPUTERNAME" -info
                
                if (Test-Connection $DomainController -Count 2 -ErrorAction SilentlyContinue) { # If the domain controller is available - check SYSVOL and NETLOGON shares

                    Write-DCTestLog -logText "Domain Controller $DomainController is available from $env:COMPUTERNAME" -pass

                    # SYSVOL Path
                    $SYSVOL = "\\$DomainController\SYSVOL"

                    if (Test-Path -Path $SYSVOL -ErrorAction SilentlyContinue) { # Connected to the SYSVOL directory correctly - don't log an error
                        Write-DCTestLog -logText "$SYSVOL is available on $DomainController from $env:COMPUTERNAME" -pass
                    }
                    else { # SYSVOL is unavailable - log an error
                        Write-DCTestLog -logText "$SYSVOL is NOT available on $DomainController from $env:COMPUTERNAME!" -fail
                    }

                    # NETLOGON Path
                    $NETLOGON = "\\$DomainController\NETLOGON"
                    
                    if (Test-Path -Path $NETLOGON -ErrorAction SilentlyContinue) { # Connected to the NETLOGON directory correctly - don't log an error
                        Write-DCTestLog -logText "$NETLOGON is available on $DomainController from $env:COMPUTERNAME" -pass
                    }
                    else { # NETLOGON is unavailable - log an error
                        Write-DCTestLog -logText "$NETLOGON is NOT available on $DomainController from $env:COMPUTERNAME!" -fail
                    }
                
                }
                
                else { # Domain controller listed is unavailable - log an error
                    Write-DCTestLog -logText "Partner Active Directory Domain Controller $DomainController is NOT available from $env:COMPUTERNAME!" -fail
                }

            }    

        }

    }

}

##-END-## -  ACTIVE DIRECTORY CHECK MODULE

##-START-## - EVENT VIEWER CHECKS - Checking for error codes and resolutions in Event Viewer

function checkEventViewer {

    <#
    Error List (Type, Error, Resolution ID)

    The sources are shortend for ease of typing.

    Currently the tested Sources are AD, DFS, DNS, DHCP

    You need the following three pieces of information: Source, Error ID, Resolutioun ID
    
    i.e.:

    Source:              "DNS"
    Error:               1234
    ResolutionCode:      9876

    ...would become

    ("DNS",1234,9876)
    #>

    # Multi-dimensional aray of locations, error codes and resolution codes
    $Errorlist = @("DFS",1202,1206),
    ("DFS",4614,4604),
    ("DFS",6016,6018),
    ("DFS",6104,6102),
    ("DFS",5008,5004),
    # To review - causing endless isues on single DCs ("DFS",4012,4602),
    # To review - check success code is correct!!    ("DFS",5014,5004),
    # To review - check success code is correct!!    ("AD",1311,1394),
    ("DNS",4013,2)

Write-Host @"

    Performing Event Viewer checks on $env:COMPUTERNAME...

"@

    $counter = 0
    foreach ($LogError in $Errorlist) { # Loop through errors in the array
        $counter++
        Write-Progress -Activity 'DCDoctor Domain Controller Checks - Checking: Event Log Errors...' -CurrentOperation $LogError[1] -PercentComplete (($counter / $ErrorList.count) * 100)

        # Expand the shortcuts above into full names
        if ($LogError[0] -eq "AD") {$LogName = "Directory Service"}
        if ($LogError[0] -eq "DFS") {$LogName = "DFS Replication"}
        if ($LogError[0] -eq "DNS") {$LogName = "DNS Server"}
        if ($LogError[0] -eq "DHCP") {$LogName = "DHCP Server"}

        $failureErrorID = $LogError[1]
        $resolutionID = $LogError[2]

        # Skip some error checks for single domain controller scenarios. One skip per line, add multiple lines if required.
        # i.e for event ID 9999
        # if (($failureErrorID -eq 9999) -And ($domainControllers | Measure-Object).Count -eq 1) { continue 
        if (($failureErrorID -eq 4012) -And ($domainControllers | Measure-Object).Count -eq 1) { continue }

        if (Get-WinEvent -FilterHashtable @{Logname=$LogName;ID=$failureErrorID} -ErrorAction SilentlyContinue) { # There is an event present - check whether it has since cleared

            # Date of last error message, converted to UK date format...
            $errorDate = (Get-WinEvent -FilterHashtable @{Logname=$LogName;ID=$failureErrorID} -MaxEvents 1 | Select-Object -ExpandProperty TimeCreated)
            $errorDateString = $errorDate.ToString("dd MMMM yyyy - hh:mm:ss")

            # Get the contents of the error message
            $errorDescription = (Get-WinEvent -FilterHashtable @{Logname=$LogName;ID=$failureErrorID} -MaxEvents 1 | Select-Object -ExpandProperty Message)

            Write-DCTestLog -logText "$LogName Error $failureErrorID Occurred on $errorDateString on Domain Controller $env:COMPUTERNAME" -info

            Write-DCTestLog -logText "$errorDescription" -plain
                   
            if (Get-WinEvent -FilterHashtable @{Logname=$LogName;ID=$resolutionID} -MaxEvents 1 -ErrorAction SilentlyContinue) { # The event has been cleared at least once (Don't know when though)

                # Get the date the error was resolved, converted to UK date format...
                $resolutionDate = (Get-WinEvent -FilterHashtable @{Logname=$LogName;ID=$resolutionID} -MaxEvents 1 | Select-Object -ExpandProperty TimeCreated)
                $resolutionDateString = $resolutionDate.ToString("dd MMMM yyyy - hh:mm:ss")

                # Get the content of the resolution message
                $resolutionDescription = (Get-WinEvent -FilterHashtable @{Logname=$LogName;ID=$resolutionID} -MaxEvents 1 | Select-Object -ExpandProperty Message)

                if ($resolutionDate -gt $errorDate) { # The resolution was after the latest error and has therefore cleared - don't log an error

                    Write-DCTestLog -logText "$LogName Resolution Event ID $resolutionID Occurred on $resolutionDateString on Domain Controller $env:COMPUTERNAME" -pass

                    Write-DCTestLog -logText "$resolutionDescription" -plain

                }

                else { # There was a resolution as determined by this "if" - however it was before the error re-appeared - log an error

                    Write-DCTestLog -logText "$LogName Error $failureErrorID has re-ocurred since it was last rectified on $resolutionDateString and is still in an errored state on Domain Controller $env:COMPUTERNAME!" -fail

                    Write-DCTestLog -logText "$errorDescription" -plain
                    
                }

            }

            else { # Because there is no resolution ID available - the error must still be and always has been present - log an error

                Write-DCTestLog -logText "$LogName Error $failureErrorID has never been rectified on Domain Controller $env:COMPUTERNAME!" -fail

                Write-DCTestLog -logText "$errorDescription" -plain
                
            }

        }

    }

}

##-END-## -  EVENT VIEWER CHECKS 

# Call the individual functions defined above

foreach ($domainController in $domainControllers) {

    # Check to make sure the tested DC isn't being excluded...
    if ($excludedServers.contains($domainController)) {

        # The server exists in the exclude list, so break out of this
        Write-DCTestLog -logText "$domainController has been excluded from the test. Skipping..." -info
        continue

    }

    # Check to see whether there is an old log folder. If so, delete it.
    if (Test-Path -Path "\\$domainController\admin$\Temp\DCDoctor") { Remove-Item -path "\\$domainController\admin$\Temp\DCDoctor" -Recurse -Force}
    
    # Create new directory structure on the destination server
    #New-Item -ItemType Directory -Path "\\$domainController\admin$\Temp\DCDoctor" -Force | Out-Null
    New-Item -ItemType Directory -Path "\\$domainController\admin$\Temp\DCDoctor\Logs" -Force | Out-Null

    # Copy any functions which may be required on the remote host
    #Copy-Item -Path "$scriptRoot\SharedFunctions" -Destination "\\$domainController\admin$\Temp\DCDoctor" -Recurse -Force | Out-Null

    Write-DCTestLog -logText "Checking $domainController" -info

    # Start a new session to the destination DC
    Write-DCTestLog -logText "Establising a remote session on $domainController..." -info
    $remoteSession = New-PSSession -ComputerName $domainController
    if ($remoteSession) { Write-DCTestLog -logText "Succesfully established a remote session on $domainController" -pass }
    else { Write-DCTestLog -logText "Failed to establish a remote session to $domainController! Please check to see whether it is available and WinRM is running." -fail; continue }

    # Import the 'Write-DCTestLog' function into the session, allowing it to be used on the remote machine.
    Write-DCTestLog -logText "Importing 'Write-DCTestLog' function" -info
    Invoke-Command -Session $remoteSession -FilePath "$scriptRoot\SharedFunctions\Write-DCTestLog\Write-DCTestLog.ps1"

    # Redirect output of log files for the remote servers.
    # This writes the output of the variables to NULL, otherwise because they aren't called in the Invoke-Command script block - ISE's show a syntax error.
    Invoke-Command -Session $remoteSession -ScriptBlock {$LogFile = "C:\Windows\Temp\DCDoctor\Logs\DCDoctor_Results.txt"; Write-Output $LogFile | Out-Null}
    Invoke-Command -Session $remoteSession -ScriptBlock {$ErrorLogFile = "C:\Windows\Temp\DCDoctor\Logs\DCDoctor_Error.txt"; Write-Output $ErrorLogFile | Out-Null}

    # Running service Checks
    Write-DCTestLog -logText "Running service checks on $domainController..." -info
    Invoke-Command -Session $remoteSession -ScriptBlock ${function:checkServices}
    Write-DCTestLog -logText "Completed Service Checks on $domainController" -info

    # Running DC Checks
    Write-DCTestLog -logText "Running Domain Controller Connectivity checks on $domainController..." -info
    Invoke-Command -Session $remoteSession -ScriptBlock ${function:checkDCConnectivity}
    Write-DCTestLog -logText "Completed Domain Controller Connectivity Checks on $domainController" -info

    # Running Event Viewer Checks
    Write-DCTestLog -logText "Running Event Viewer checks on $domainController..." -info
    Invoke-Command -Session $remoteSession -ScriptBlock ${function:checkEventViewer}
    Write-DCTestLog -logText "Completed Event Viewer Checks on $domainController" -info

    # Get the contents of the remote log file to add back to the local log file.
    $remoteLogFile = (Get-Content -Path "\\$domainController\admin$\Temp\DCDoctor\Logs\DCDoctor_Results.txt")

    # Dump the contents of the remote file into the local log file
    Write-Output $remoteLogFile | Out-File $LogFile -Append

    # If there is an error log, add it to the error log locally
    if (Test-Path "\\$domainController\admin$\Temp\DCDoctor\Logs\DCDoctor_Error.txt") {

        # Get the contents of the remote error log
        $remoteErrorLogFile = (Get-Content -path "\\$domainController\admin$\Temp\DCDoctor\Logs\DCDoctor_Error.txt")

        # Dump the contents of the remote error log into the local error log
        Write-Output $remoteErrorLogFile | Out-file $ErrorLogFile -Append
    }

    # Tidy up and remove the logs from the remote server
    Remove-Item -path "\\$domainController\admin$\Temp\DCDoctor" -Recurse -Force

    # End the Remote PS Session
    Remove-PSSession -Session $remoteSession

}

##-START-## - E-MAIL

if ($sendMailReport -eq "YES") { # E-Mail Reporting enabled

    if ((!(Test-Path $ErrorLogFile)) -and $sendMailReportOnPass -eq "YES") { # The error file doesn't exist - therefore the tests must have passed

        $subject = "DCDoctor PASS for $env:COMPUTERNAME.$env:USERDNSDOMAIN on $date" # E-Mail Subject
 
        $eMailBody = "Dear User,<br /><br />Good news, <b>$env:COMPUTERNAME.$env:USERDNSDOMAIN</b> has passed the DCDoctor tests on $date.<br /><br />Please see attached a summary of the scan for your reference.<br /><br />Regards,<br />DCDoctor<br /><br />"

    }

    if ((Test-Path $ErrorLogFile) -and $sendMailReportOnFail -eq "YES") { # The error file doe exist - therefore the tests must have failed at some point

        $subject = "DCDoctor FAIL for $env:COMPUTERNAME.$env:USERDNSDOMAIN on $date" # E-Mail Subject

        $eMailBody = "Dear User,<br /><br />Please note, <b>$env:COMPUTERNAME.$env:USERDNSDOMAIN</b> has failed the DCDoctor tests on $date.<br /><br />Please see attached a summary of the errors.<br /><br />Regards,<br />DCDoctor<br /><br />"

    }

    Write-DCTestLog -logText "Sending E-Mail Message..." -info

    $smtpSecurePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force # Convert the password in the config file to a secure string.

    $smtpCredentials = New-Object System.Management.Automation.PSCredential ($smtpUsername, $smtpSecurePassword) # Assemble a variable containing the encrypted credentials.

    # Try to send E-Mail alert and catch a failure...

    try { Send-MailMessage -To $sendMailTo -From $sendMailFrom -Subject $subject -Body $eMailBody -SmtpServer $smtpServer -Port $smtpServerPort -Credential $smtpCredentials -Priority High -Attachments $LogFile -BodyAsHtml -ErrorAction Stop }
    catch {

        # Get the error returned from the Send-MailMessage cmdlet.
        $eMailError = $_

        # State the reason why in the test log.
        Write-DCTestLog -logText "Failed to send E-Mail (ERROR: $eMailError)!" -eMailfail

        # Put a red warning on the PowerShell window (if being run in console mode).
        Write-Host @"

ERROR SENDING E-MAIL!!

Please check $eMailErrorLogFile for more information...

"@ -ForegroundColor Yellow -BackgroundColor Red

        # To help bring attention, pause the script for a period of time.
        Start-Sleep -Seconds 5
        
    }

}

##-END-## -  E-MAIL

# Complete and end script
$date = (Get-Date -Format "dd/MM/yyy HH:mm:ss")
Write-DCTestLog -logText "Completed test on $date" -plain

Write-Host @"

Completed test on $date

$logo
"@
