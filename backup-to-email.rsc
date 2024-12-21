# ROS 7.16 tested
# This script is particularly useful in automated backup and email systems where it’s important to ensure that backup files are emailed successfully and that temporary files are removed after the process is complete.

:local email "backup.66@aol.com"
:local namedatetime2 ("$[/system identity get name]-backup-" . [:pick [/system clock get date] 0 10] . "-" . [:pick [/system clock get time] 0 8] . ".backup")
:local export ("$[/system identity get name]-export-" . [:pick [/system clock get date] 0 10] . "-" . [:pick [/system clock get time] 0 8] . ".rsc")

/system backup save name="$namedatetime2"
/export show-sensitive terse compact file="$export"

# Loop to check if files exist
:while ([:len [/file find name="$namedatetime2"]] = 0 || [:len [/file find name="$export"]] = 0) do={
    :delay 1
}

# Get current log size to track new entries
:local initialLogSize [:len [/log find]]

# Attempt to send the email
/tool e-mail send file=("$namedatetime2,$export") to="$email" body="See attached file" subject=("$[/system identity get name]-Backup")



:local emailStatus ""
:local loopRunning true

:while ($loopRunning) do={
    # Get the email last-status as a string
    :set emailStatus [/tool e-mail get last-status as-string]

    # Log the current status
    :log info ("Current email status: " . $emailStatus)

    # Check if the email is succeeded or failed
    :if (($emailStatus = "succeeded") || ($emailStatus = "failed")) do={
        :log info "Email status check complete: $emailStatus"
        :set loopRunning false
    }


    # Wait for a short delay before checking again
    :delay 5
}


# Remove the files after checking email status
/file remove [find name="$namedatetime2"]
/file remove [find name="$export"]
