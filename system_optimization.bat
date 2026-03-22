@echo off
:: Post-Deployment Optimization and Provisioning Script
:: Performance tuning, debloat, and automated domain join logic.
setlocal enabledelayedexpansion

:: 0. PRIVILEGE CHECK
net session >nul 2>&1
if %errorlevel% neq 0 (echo [ERROR] Administrative privileges required. & pause & exit) [cite: 5]

:: 1. HOSTNAME GENERATION & TIME SYNC
:: Generates unique hostname based on BIOS Serial Number[cite: 5].
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Bios).SerialNumber.Trim()"`) do set "serial=%%a"
set "target=PC-%serial%"
set "target=%target:~0,15%" [cite: 5]

tzutil /s "SA Pacific Standard Time" >nul [cite: 5]
w32tm /config /manualpeerlist:"time.windows.com,0x1" /syncfromflags:manual /reliable:YES /update >nul [cite: 6]

:: 2. SYSTEM DEBLOAT
:: Removes non-essential applications and optimizes web services[cite: 6, 7].
powershell -NoProfile -Command "Get-AppxPackage -AllUsers | Where-Object {$_.Name -match 'Spotify|Disney|TikTok|WebExperience'} | Remove-AppxPackage -ErrorAction SilentlyContinue" [cite: 7]
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul [cite: 7]

:: 3. HARDWARE-SPECIFIC PROVISIONING
:: Detects hardware manufacturer to deploy specific driver management tools[cite: 9, 10].
for /f %%i in ('powershell -NoProfile -Command "$sys=Get-CimInstance Win32_ComputerSystem; if($sys.Manufacturer -match 'Lenovo'){10} else {0}"') do set "HW_CODE=%%i" [cite: 9]

if "%HW_CODE%"=="10" (
    :: Lenovo System Update deployment [cite: 9]
    start /wait D:\applications\oem_update_tool.exe /VERYSILENT /NORESTART
)

:: 4. KERNEL & PERFORMANCE TUNING
:: Disables VBS/HVCI for CPU overhead reduction and optimizes RAM management[cite: 11].
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f >nul [cite: 11]
powershell -NoProfile -Command "Disable-mmagent -MemoryCompression" >nul 2>&1 [cite: 11]
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul [cite: 11]

:: 5. REMOTE ACCESS CONFIGURATION
:: Resets AnyDesk Unique ID for cloned instances[cite: 12].
net stop AnyDesk >nul 2>&1
taskkill /F /IM AnyDesk.exe >nul 2>&1
if exist "%ProgramData%\AnyDesk\system.conf" del /Q /F "%ProgramData%\AnyDesk\system.conf" >nul 2>&1 [cite: 12]
net start AnyDesk >nul 2>&1 [cite: 12]

:: 6. AUTOMATED DOMAIN JOIN
:: Verifies domain status and executes join using secure credential handling[cite: 13, 14, 17].
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$sys = Get-CimInstance Win32_ComputerSystem; ^
if ($sys.PartOfDomain -and ($sys.Name -eq '%target%')) { ^
    Write-Host '[SKIP] Already in domain.' -ForegroundColor Green; ^
} else { ^
    $sec = ConvertTo-SecureString 'PASSWORD_PLACEHOLDER' -AsPlainText -Force; ^
    $cred = New-Object System.Management.Automation.PSCredential('your.domain\admin', $sec); ^
    Add-Computer -DomainName 'your.domain' -NewName '%target%' -Credential $cred -Force -Restart:$false; ^
}" [cite: 14, 16, 17, 18]

:: 7. FINAL CLEANUP
powershell -NoProfile -Command "Clear-RecycleBin -Confirm:$false; ipconfig /flushdns" >nul 2>&1 [cite: 19, 20]
pause