#timestamp function
filter timestamp {"$(get-date -Format G): $_"}

$scriptname = $MyInvocation.MyCommand.Name
$output = ".\$($scriptname).log"
##=============================================

#import file with new passwords
$csv = import-csv .\oneclass.csv

#test for output file
if (!(test-path $output)) { New-Item -Path $output | out-Null}
#clear output file
clear-content -path $output -Force

$errorcount=0
foreach ($pupil in $csv) {

    $password = $pupil.Password
        
    $error.clear()
    
    try { 
        Set-ADAccountPassword -Identity $($pupil.Username) -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $($password) -Force)
        }
    catch { 
        add-content -path $output "$($pupil.FirstName),$($pupil.LastName) : $($error)" | timestamp
        $errorcount++ }    
    
    if (!$error)  { 
            Write-Output "Done $($pupil.Firstname) $($pupil.LastName) $($password)"
        }


}
if ($errorcount -gt 0) { Write-Output "$($errorcount) Errors occurred - see log"}