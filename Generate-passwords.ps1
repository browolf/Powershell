#This script takes an existing file containing passwords and makes a new file with different passwords


#timestamp function
filter timestamp {"$(get-date -Format G): $_"}
#get script name
#$scriptname = $MyInvocation.MyCommand.Name
#output file
$output = ".\newpasswords.csv"
##================================================

#import file with existing passwords
$csv = import-csv .\2021passwords.csv

#test for output file
if (!(test-path $output)) { New-Item -Path $output | Out-Null}
#clear output file
clear-content -path $output -Force

#set arrays of words
$colours = @('Green','Yellow','Blue','Black','Purple','Pink','Orange', "Maroon","Happy","Bored","Sleepy","Brave","Short","Tall")
$animals = @('monkey','donkey','snake','horse','rabbit','shark','mouse','tiger', 'zebra', 'panda', 'cabbage', 'potato', 'whale', 'Bear')

#write headers of output file
"FirstName,LastName,Username,Password,EmailAddress,RegGroup,Class" | out-file -Filepath .\newpasswords.csv 

#for each pupil
foreach ($pupil in $csv){
    #make new password
    $col = Get-Random -InputObject $colours
    $ani = Get-Random -InputObject $animals
    $password = "1" + $col + $ani

    #write output file containing passwords
    $error.clear()
    try {
    add-content -path $output "$($pupil.FirstName),$($pupil.LastName),$($pupil.Username),$($password),$($pupil.EmailAddress),$($pupil.RegGroup),$($pupil.Class)" 
    } catch {
        Write-Output "Error for $($pupil.Firstname) $($pupil.LastName) $($error) " | timestamp 
    }


    if (!$error) {
        Write-Output "Done $($pupil.FirstName) $($pupil.LastName)" | timestamp
    } 
    
}
