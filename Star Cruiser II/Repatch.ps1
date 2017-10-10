cls

Copy-Item ".\HDI_Original\Star Cruiser II.hdi" ".\HDI_Patched\Star Cruiser II.hdi" -Confirm:$false
.\1.Hack-COMfile.ps1
.\2.Parse-STRs.ps1
.\3.Parse-Direct.ps1
.\4.Parse-Intros.ps1
.\5.Parse-Ending.ps1
.\6.PackFiles.ps1
