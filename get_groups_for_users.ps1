# This script fetches a users group memberships and then emails them the list. 
# need Powershell 7 installed to use "ReplyTo"
# if using Windows Terminal need to change the default PS version
# https://stackoverflow.com/questions/66447566/how-to-set-powershell-7-as-default-and-remove-other-versions
# but then you need to follow these instructions to make AzureAD work 
# https://github.com/PowerShell/PowerShell/issues/12234#issuecomment-608414409


# Import the required module
Import-Module AzureAD

#fixed variables
$administrator = "admin_email@yourdomain"
$replyaddress = "reply_address@yourdomain"

#credentials to run the script

$password = Read-Host -Prompt "Enter admin password" -AsSecureString
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $administrator, $password

# Connect to Azure AD using an admin account
try {
    Connect-AzureAD -Credential $Credential -ErrorAction Stop |out-null
} catch {
        if ($_.Exception.Message -like "*One or more errors occurred.*") {
        Write-Host "The specific error 'Connect-AzureAD: One or more errors occurred.' has occurred."
        write-Host "Did you use the correct password?"
        exit
    }
    else {
        Write-Host "Failed to connect to Azure AD: $($_.Exception.Message)"
        exit
    } 
}



# Specify the user's UserPrincipalName
$userUPN = Read-Host -Prompt "Enter the UserPrincipalName of the user"

# Get the user's group memberships
$groups = Get-AzureADUserMembership -ObjectId $userUPN

# Loop through each group and print the DisplayName
foreach ($group in $groups) {
    Write-Output $group.DisplayName
}

# Initialize an empty array to hold the group names
$groupNames = @()

# Loop through each group and add the DisplayName to the array
foreach ($group in $groups) {
    $groupNames += $group.DisplayName
}

#Convert the array of group names to a string, with each name on a new line
$groupNamesString = $groupNames -join "`r`n"

$sendMailMessageArray = @{
    From = $administrator
    To = $userUPN
    Subject = "Your Office365 groups"
    Body = "Here are the groups(including teams & distribution lists) you are a member of:`r`n`r`n$groupNamesString`r`n`r`nIf you want to be removed from any of these groups (may represent teams and distribution lists), please reply to this email."
    SmtpServer = "smtp.office365.com"
    Credential = $credential
    UseSsl = $true
    Port = 587
    replyTo = $replyaddress
}

#send the data
try {
    send-MailMessage @sendMailMessageArray
    write-host "Email Sent"
} catch {
    Write-Host "Failed to send email: $($_.Exception.Message)" 
}


