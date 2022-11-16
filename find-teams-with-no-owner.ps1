try {
    $null = Get-CsTenant
} catch {
    $credential = Get-Credential
    Connect-MicrosoftTeams -credential $credential
}

get-team | select-object GroupId,DisplayName,MailNickName  | foreach-object {

    if ($_.groupid) {

        $owners = Get-TeamUser -groupid $_.GroupId -Role Owner

        if (!($owners)) {
            Write-Output $_.displayname
        }
    
    }

}
