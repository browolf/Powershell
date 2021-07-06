#Set-executionpolicy RemoteSigned -force
#default is set-executionpolicy localmachine -force


function Add-Sims {
    $newguid = [guid]::NewGuid().tostring()
    $agentArgs = @(
        "/i"
        "`"\\server\shared$\AgentInstall\SOLUS3AgentInstaller_x64.msi`""
        "AGENTSERVICEADDRESS=`"net.tcp://localhost:52966`""
        "AGENTID=`"{$newguid}`""
        "DEPLOYMENTSERVERADDRESS=`"net.tcp://server:52965`""
        "RSAKEYPATH=`"\\server\shared$\AgentInstall\`""
        "/qn"
        "/l*v"
        "`"\\server\shared$\LOGS\$env:computername-solus.log`""  
    )
    write-output "Installing sims..."
    start-process msiexec.exe -ArgumentList $agentArgs -wait -Verb RunAs
    #Write-Output $agentArgs
    $simsArgs = @(
        "/s"
        "{quiet}"
        )
    start-process '\\server\shared$\SIMSApplicationSetup.exe' -ArgumentList $simsArgs -wait -Verb Runas
    Copy-Item "\\server\shared$\sims.ini" -Destination "$env:temp\" -force
    move-Item "$env:temp\sims.ini" -Destination "c:\windows\sims.ini" -force 
}
