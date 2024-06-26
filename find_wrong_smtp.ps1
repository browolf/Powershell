#This script finds users that have a proxy adress with SMTP (capitals) instead of lowercase. 
#A mistake the user creation script caused this. 
#SMTP causes the proxy address to become their primary email address in Office365
#the list wasn't that long so I manually fixed the users. 
#by some fortunate quirk when you remove the email, it goes back in the add textbox so you can just change SMTP to smtp and add back. 

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU and the domain
$OU = "OU=azure,OU=staff,dc=yourdomain"

# Get users in the specified OU
$users = Get-ADUser -Filter * -SearchBase $OU -Properties proxyAddresses

# Initialize an array to store users with SMTP in proxyAddresses
$usersWithSMTP = @()

# Loop through each user and check the proxyAddresses attribute
foreach ($user in $users) {
    if ($user.proxyAddresses) {
        foreach ($address in $user.proxyAddresses) {
            #Write-Output ($address)
            if ($address -cmatch "^SMTP:") {
                $usersWithSMTP += $user
                break
            }
        }
    }
}

# Output the list of users with SMTP in proxyAddresses
$usersWithSMTP | Sort-Object Name | Select-Object Name, SamAccountName, proxyAddresses | Format-Table -AutoSize
