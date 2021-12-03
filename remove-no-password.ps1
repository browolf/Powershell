#timestamp function 
filter timestamp {"$(get-date -Format G): $_"} 
#get script name 
$scriptname = $MyInvocation.MyCommand.Name 
#output file 
$log = ".\$($scriptname).csv" 
#test for log file 
if (!(test-path $log)) { New-Item -Path $log | Out-Null} 
else { clear-content -path $log -Force } 
##================================================ 


get-aduser -filter * -properties * | select-object samaccountname,useraccountcontrol | ForEach-Object {    
    if ($_.useraccountcontrol -eq "544") {
        write-output "$($_.samaccountname) - $($_.useraccountcontrol)" 
        #Add-Content -path $log "$($_.samaccountname),$($_.useraccountcontrol)" 
        set-adaccountcontrol $_.samaccountname -PasswordNotRequired $false
    }
}

