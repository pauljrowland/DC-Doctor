function Write-DCTestLog ([string]$logText,[switch]$warn,[switch]$pass,[switch]$fail,[switch]$plain,[switch]$info,[switch]$eMailFail) {

    # Function to write the log file. This accepts the "logTtext" parameter which created the variable "$logText"
    # and switches to decide the type of text to display, i.e.:
    # Write-DCTestLog -logText "This is a warning" -warn

    $date = (Get-Date -Format "dd/MM/yyy HH:mm:ss") # Get date and format for readability.

    if ($pass) { # Checks passed.
        $outputLogText = "$date   P!:   $logText`n" # Log output and add "P!:" to line.
        $fgColor = "green" # Change colour to green.
    }

    if ($fail) { # Checks failed.
        $outputLogText = "$date   E!:   $logText`n" # Log output and add "E!:" to line.
        $fgColor = "red" # Change colour to red.
    }

    if ($info) { # Information line to be written.
        $outputLogText = "$date   I!:   $logText`n" # Log output and add "I!:" to line.
        $fgColor = "yellow"  # Change colour to yellow.
    }

    if ($warn) { # Warning line to be written.
        $outputLogText = "$date   W!:   $logtext`n" # Log output and add "W!:" to line.
        $fgColor = "yellow"  # Change colour to yellow.
    }

    if ($plain) { # Plain white text block.
        $outputLogText = "$logText`n" # Text to output.
        $fgColor = "white"  # Change colour to white.
    }

    if ($eMailfail) { # E-Mail failed to send.
        $outputLogText = "$date   E!:   $logText`n" # Log output and add "E!:" to line.
        $fgColor = "red" # Change colour to red.
    }

    Write-Host $outputLogText -ForegroundColor $fgColor # Display the text on-screen if the script is being watched by a user.

    # This will output to the text file(s)depending on the type. Once the script ha completed, there may be an erro file. If E-Mails
    # are configured, the admin will be alerted with a copy of the report. If the error file does not exist - no E-Mail is sent.

    $outputLogText | Out-File -FilePath $LogFile -Append # Output the content to the log file.

    if ($fail) { # Established that there is a failure. In this case, add details to the error log ready to be E-Mailed.
        if (!(Test-Path -Path $ErrorLogFile -ErrorAction SilentlyContinue)) { # Does the error file exist? If not, make it...
            Write-Output "Error log for $env:COMPUTERNAME.$env:USERDNSDOMAIN`n"  | Out-File -FilePath $ErrorLogFile -Append
        }
        $outputLogText | Out-File -FilePath $ErrorLogFile -Append # Output the error content to the error log file.
    }

    if ($eMailFail) { # E-Mail failed to send. Logging now in a seperate log.
        $logo | Out-File -FilePath $eMailErrorLogFile -Append # Add the logo to the E-Mail error log
        Write-Output "Failed to send E-Mail (ERROR: $eMailError) for $env:COMPUTERNAME.$env:USERDNSDOMAIN`n"  | Out-File -FilePath $eMailErrorLogFile -Append
    }

}