  # Stop-Process -Name explorer -ErrorAction SilentlyContinue
  cmd /c taskkill /f /im explorer.exe | Out-Null
  Stop-Process -Name StartAllBackCfg -ErrorAction SilentlyContinue
  
  $DLL = "StartAllBack\StartAllBackX64.dll"
  $UserDLL = "$Env:LocalAppData\$DLL"
  $SystemDLL64 = "$Env:ProgramFiles\$DLL"
  $SystemDLL32 = "${Env:ProgramFiles(x86)}\$DLL"
  $Paths = @()
  if(Test-Path -Path $UserDLL) { $Paths += ,$UserDLL }
  if(Test-Path -Path $SystemDLL64) { $Paths += ,$SystemDLL64 }
  if(Test-Path -Path $SystemDLL32) { $Paths += ,$SystemDLL32 }

  foreach($Path in $Paths) {
   $Backup = "$Path.bak"
   if(Test-Path -Path $Backup) {
    Remove-Item -Path $Path -Force
    Rename-Item -Path $Backup -NewName $Path
   } else {
    Copy-Item -Path $Path -Destination $Backup
    $Bytes = Get-Content $Path -Raw -Encoding Byte # Read as ByteStream
    $String = $Bytes.ForEach('ToString', 'X') -join ' '

    # Replace 
    $String = $String -replace '\b48 89 5C 24 8 55 56 57 48 8D AC 24 70 FF FF FF\b(.*)', '67 C7 1 1 0 0 0 B8 1 0 0 0 C3 90 90 90$1'

    [byte[]]$ModifiedBytes = -split $String -replace '^', '0x'
    Set-Content -Path $Path -Value $ModifiedBytes -Encoding Byte # Save as ByteStream
   }
  }

  Start-Process explorer
