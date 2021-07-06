 $host.ui.RawUI.WindowTitle = "LSA Powershell"
Set-PSReadLineOption -colors @{
  Operator           = 'Cyan'
  Parameter          = 'Cyan'
  String             = 'White'
}
Import-Module Add-sims
