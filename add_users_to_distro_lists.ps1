# Import the ImportExcel module
Import-Module ImportExcel

$cred = get-credential -Message "Put in password" -username "<admin email that doesn't have 2fa>"
connect-Exchangeonline -credential $cred 

#this is an xlsx file.
#6 columns represent 6 distribution lists
#the first row is the name of the lists
#each column contains the names of the people to be added to each list. 
$excelFilePath = "input_data.xlsx"

# Import the Excel file as an object array
$data = Import-Excel -Path $excelFilePath

# Check the columns by using the headers of the first row in the data
$columnHeaders = $data[0].PSObject.Properties.Name

# Initialize a list to store failed additions
$failedEntries = @()

# Loop through each column based on the headers
foreach ($column in $columnHeaders) {
    
    # Set the distribution list name based on the column name
    $distributionListName = "$($column)"
    
    # Get the names in the current column
    $names = $data | Select-Object -ExpandProperty $column
    
    # Loop through each name and try adding them to the distribution list
    foreach ($name in $names) {
        if ($name) {  # Check to make sure the cell is not empty
            Write-Output "Attempting to add $($name) to $($distributionListName)"
            try {
                # Attempt to add the name to the distribution list
                Add-DistributionGroupMember -Identity $distributionListName -Member $name -ErrorAction Stop
            }
            catch {
                # Log the failed addition with column and name
                $failedEntries += [PSCustomObject]@{
                    DistributionList = $distributionListName
                    Name             = $name
                    ErrorMessage     = $_.Exception.Message
                }
                Write-Output "Failed to add $($name) to $($distributionListName): $($_.Exception.Message)"
            }
        }
    }
}

#this output is necessary as there is invariable errors. 
#either their name is written differently to their display name
#or there's a typo
#or office contains knowledge of external emails they've used in the past. 
#i found  i had to add 10-30% of the people manually afterwards but this still cut down the job massively. 

# Output the list of failed additions (if any)
if ($failedEntries.Count -gt 0) {
    Write-Output "The following names could not be added to their respective distribution lists:"
    $failedEntries | Format-Table -AutoSize
    
    # Optionally export the failures to a CSV file
    $failedEntries | Export-Csv -Path "FailedAdditions.csv" -NoTypeInformation -Encoding UTF8
} else {
    Write-Output "All names were successfully added to their respective distribution lists."
}
