#inputformat
#firstname, Surname, Admission_number, computer class or form

$thisyear = "2022"
$inputf = "sims$($thisyear).csv"
$output = "$($thisyear).csv"

if (test-path -Path ".\$($output)"){
    remove-item $output
}


function Get-Pass {
    #set arrays of words
    $colours = @('Wild','Bright','Busy','Green','Blue','Purple','Pink','Clever', "Cold","Happy","Sleepy","Brave","Short","Tall", "Helpful", "Clean", "Cute", "Super", "Sporty", "Silver", "Gold", "Fast")
    $animals = @('goat','elephant','penguin','donkey','snake','horse','rabbit','shark','mouse','tiger', 'zebra', 'panda', 'cabbage', 'potato', 'whale', 'bear', 'pencil', 'tree', 'fish', "frog", "toad")
    #make new password
    $col = Get-Random -InputObject $colours
    $ani = Get-Random -InputObject $animals
    return "1" + $col + $ani
}

import-csv $inputf | ForEach-Object {
    $password = Get-Pass
    $securepass = ConvertTo-SecureString -String $password -AsPlainText -Force
    #write-output "Processing $($_.firstName) $($_.surName)"
  
    #remove non characters
    $pattern="[^a-zA-Z]"
    $firstname = $_.firstName -replace $pattern
    $surname = $_.surName -replace $pattern
    #$username = $_.adno
    $office = $_.adno

   
    #construct username
    $username = "$(get-date -Format 'yy')$($firstname.substring(0,1))$($surname)"
    $res = ([ADSISearcher] "sAMAccountName=$username").FindOne()

    #if use name exists  = bad
    if ($res -ne $null) {
        #need to find an acceptable username
        $prefix=2

        while ($true) {
            $testuser = $username + $prefix
            #write-output ("testing $($testuser)")
            $res = ([ADSISearcher] "sAMAccountName=$testuser").FindOne()
            if ($res -ne $null) {
                #bad
                $prefix++}
            else {
                $username = $testuser
                break

            }    
        }
    } 
    
    $Displayname = "$($_.firstName) $($_.surName)"
    #test if CN name exists 
    $res = ([ADSISearcher] "cn=$displayname").FindOne()

    #if displayname exists
    if ($res -ne $null) {
        #need to find an acceptable display name
        $prefix=2

        while ($true) {
            $testdisplayname = $displayname + $prefix
            #write-output ("testing $($testuser)")
            $res = ([ADSISearcher] "cn=$testdisplayname").FindOne()
            if ($res -ne $null) {
                #bad
                $prefix++}
            else {
                $displayname = $testdisplayname
                break

            }    
        }
    } 



    
    #fields
    $email = "$($username)@domain.org".ToLower() 
    $homedirectory = "\\server\pupils$\$($username)"
    $samaccountname = "$($username)".ToLower()
    

   
    $error.clear()
    try {New-ADUser -name $Displayname `
        -AccountPassword $securepass `
        -AccountNotDelegated $false `
        -Description "Year starting $($thisyear)" `
        -DisplayName $Displayname `
        -EmailAddress $email `
        -GivenName $_.firstName `
        -Surname $_.surName `
        -HomeDirectory $homedirectory `
        -HomeDrive "Z:" `
        -PasswordNeverExpires $false `
        -SamAccountName $samaccountname `
        -UserPrincipalName $email `
        -Office $office `
        -path "OU=Azure,OU=pupils,DC=school" `
        -enabled $true `
        -scriptPath "pupils.bat"
        }
    catch {
        write-output "Error adding $($firstname) $($surname)"
        Write-Output $error
        exit
    }

    #adduser to 365 students
    $error.Clear()
    try {
        Add-ADGroupMember -identity "365Students" -members $samaccountname
    } catch {
        Write-Output "Error adding user to 365Students"  
    }

    #adduser to allstudentsecurity
    $error.Clear()
    try {
        Add-ADGroupMember -identity "allstudentsecurity" -members $samaccountname
    } catch {
        Write-Output "Error adding user to allstudentsecurity"  
    }

    #adduser to allstudentTeam
    $error.Clear()
    try {
        Add-ADGroupMember -identity "AllStudentTeam" -members $samaccountname
    } catch {
        Write-Output "Error adding user to AllStudentTeam"  
    }


    #create folder
    $User = Get-ADUser -Identity $samaccountname
    $homeshare = new-item -path $homedirectory -ItemType Directory -Force
    $acl = Get-Acl $homeshare
    $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Modify"
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User.SID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    $acl.AddAccessRule($AccessRule)

    try { Set-Acl -Path $homeShare -AclObject $acl }
    catch { write-output "Error creating $($homeshare): $($error)"}

    If (!$error) {write-output "$homedirectory created"}
    
    Write-Output "Name: $($_.firstName) $($_.surName),Username:$($username) Password:$($password) Email: $($email) "

    $userOBJ = New-Object -TypeName psobject -Property @{
        'firstname' = $_.firstName
        'surname' = $_.surName
        'username' = $samaccountname
        'password' = $password
        'email' = $email
        #'form' = $_.form
        'cclass' = $_.cclass
    }

    $userOBJ | Export-Csv $output -Append -NoTypeInformation

   

    


}
