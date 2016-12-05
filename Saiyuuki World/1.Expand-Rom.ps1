Write-Host
Write-Host "Expand-ROM"

. .\Common.ps1

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$file = [System.IO.File]::ReadAllBytes($originalRomPath)

$header = @()
0..15 | % {$header += $file[$_]}


$prg1st = ([Byte[]] (,0xFF * (($header[4]-1)*0x4000)))
$prg1st = [AddBytes]::Add($prg1st, $file, 16, ((($header[4]-1)*0x4000)-1))

$extra = ([Byte[]] (,0x00 * ($header[4]*0x4000)))

$prgLast = ([Byte[]] (,0xFF * 0x4000))
$prgLast = [AddBytes]::Add($prgLast, $file, ($file.Count - 0x4000), 0x3FFF)

$patchedRom = $header + $prg1st + $extra + $prgLast
$patchedRom[4] = 16

[System.IO.File]::WriteAllBytes($patchedRomPath,$patchedRom)

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
