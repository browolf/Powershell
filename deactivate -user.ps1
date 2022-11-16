#This script will remove membership of Distribution lists, office365 groups and AD groups, and reset licenses back to generic license (in order to retain mailbox) 

#need to edit $adminusername and the license name being assigned to the user


#connect to office365 services
try 
{ $var = Get-AzureADTenantDetail } 
catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException]{
    $AdminUserName = "email@domain"
    $securePassword = read-Host -Prompt "input password" -AsSecureString
    $Credential = New-Object System.Management.Automation.PSCredential -argumentlist $AdminUserName, $SecurePassword
    Connect-AzureAD -Credential $Credential  
    Connect-MsolService -Credential $Credential
}

Connect-ExchangeOnline -UserPrincipalName $AdminUserName


$email = Read-Host -Prompt "input user email address"

#azure ad groups
$User = Get-AzureADUser -ObjectId $email
$Memberships = Get-AzureADUserMembership -ObjectId $User.ObjectId | Where-object { $_.ObjectType -eq "Group" }
$Memberships | ForEach-Object {

    Remove-AzureADGroupMember -ObjectId $_.ObjectId -memberid $user.objectId
    Remove-DistributionGroupMember -identity $_.displayname -member $email -Confirm:$false
    Remove-ADGroupMember -Identity "Allstaff" -Members $email -Confirm:$false
 

}

if ($memberships.displayname -eq "encrypted_mail_users") {
    Remove-DistributionGroupMember -identity "encrypted_mail_users" -member $email -Confirm:$false
}

if ($memberships.displayname -eq "allstaff") {
    Remove-DistributionGroupMember -identity allstaff@lythamhigh.lancs.sch.uk -member $email -Confirm:$false
}



#reset licenses
(get-MsolUser -UserPrincipalName $email).licenses.AccountSkuId |foreach-object { Set-MsolUserLicense -UserPrincipalName $email -RemoveLicenses $_}

set-msoluserlicense -userprincipalname $email -addlicenses 00000000:STANDARDWOFFPACK_IW_FACULTY



Get-AzureADUserMembership -ObjectId $User.ObjectId | Where-object { $_.ObjectType -eq "Group" } | Select-Object DisplayName

Disconnect-ExchangeOnline -Confirm:$false
