#this script creates computer accounts in AD and adds them to a group
#This saves us time imaging computers as we would normally have to add the acccount to the wifi group and reboot after imaging had occurred. 
#usage the script creates x additional accounts from a new computer name that ends with a number. Our accounts are in form e.g. "DELL-5490-25"

function CheckIfComputerAccountExists {
    param (
        [string]$computerName
    )

    try {
        $computer = Get-ADComputer -Identity $computerName.ToUpper()
    } catch {
        # Computer doesn't exist
    }

    return $computer
}



# Ask for computer name input
$computerName = Read-Host "Enter the computer name (ending with a number):"

# Validate that the computer name ends with a number
if ($computerName -match '^(.*?)(\d+)$') {
    $baseName = $matches[1]
    $number = [int]$matches[2]
   
    if ($computer) {
        Write-Host "Computer account '$computerName' already exists in Active Directory. Exiting..."
        exit
    }


    # Ask for the number increment
    $increment = Read-Host "Enter the number increment:"

    # Create a list of computer names
    $computerNames = @()
    for ($i = $number; $i -lt ($number + $increment); $i++) {
        $computer = "$baseName$i".ToUpper()
        $computerNames += $computer
    }

    # Active Directory information
    $ouPath = "ou=secured laptops,dc=domain,dc=etc"
    $group = "radius_wifi"


    # Loop through each computer name
    foreach ($computer in $computerNames) {
        # Create Active Directory computer account
        New-ADComputer -Name $computer -Path $ouPath

        # Wait until the computer account exists
        do {
        Start-Sleep -Seconds 1
        $existingComputer = CheckIfComputerAccountExists -computerName $computer
        } until ($existingComputer)

        # Add the computer account to the "school laptops" group
        Add-ADGroupMember -Identity $group -Members ($computer + "$")
        Write-Host "Created computer account '$computer' and added to the '$group' group."
    }
} else {
    Write-Host "Invalid computer name. It should end with a number."
}
