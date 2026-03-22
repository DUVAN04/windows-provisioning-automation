@echo off
:: Windows 11 Automated Deployment Script (UEFI/GPT)
:: Automates partitioning, image application, and offline registry configuration.
setlocal enabledelayedexpansion

:: 1. STORAGE PROVISIONING
:: Verifies source image and initializes GPT partition structure[cite: 1].
if not exist "D:\automation\install.wim" (
    echo [ERROR] install.wim not found in D:\automation\
    pause & exit
)

echo [+] Preparing GPT/UEFI partitions...
(
echo sel disk 0
echo clean
echo convert gpt
echo create part efi size=260
echo format quick fs=fat32 label="System"
echo assign letter=S
echo create part msr size=16
echo create part pri
echo format quick fs=ntfs label="Windows"
echo assign letter=W
) | diskpart >nul [cite: 2]

:: 2. IMAGE APPLICATION
:: Applies WIM image using Compact mode for storage efficiency[cite: 2].
echo [+] Applying Windows 11 Image...
dism /Apply-Image /ImageFile:"D:\automation\install.wim" /Index:1 /ApplyDir:W:\ /Compact /Verify [cite: 2]

:: 3. OFFLINE CONFIGURATION (OOBE & AUTOLOGON)
:: Injects registry keys into the offline software hive to bypass setup requirements[cite: 2].
reg load HKLM\OFFLINE_SOFT W:\Windows\System32\config\SOFTWARE >nul [cite: 2]
set "OOBE=HKLM\OFFLINE_SOFT\Microsoft\Windows\CurrentVersion\Setup\OOBE"
reg add "%OOBE%" /v UnattendCreatedUser /t REG_DWORD /d 1 /f >nul [cite: 2]
reg add "%OOBE%" /v OOBEComplete /t REG_DWORD /d 1 /f >nul [cite: 2]
reg add "%OOBE%" /v BypassNRO /t REG_DWORD /d 1 /f >nul [cite: 2]

set "WLOGON=HKLM\OFFLINE_SOFT\Microsoft\Windows NT\CurrentVersion\Winlogon"
reg add "%WLOGON%" /v DefaultUserName /t REG_SZ /d AdminUser /f >nul [cite: 2]
reg add "%WLOGON%" /v AutoAdminLogon /t REG_SZ /d 1 /f >nul [cite: 2]
reg add "%WLOGON%" /v ForceAutoLogon /t REG_SZ /d 1 /f >nul [cite: 2]
reg unload HKLM\OFFLINE_SOFT >nul [cite: 2]

:: 4. POST-INSTALLATION SCRIPTS
:: Configures local administrative user account[cite: 2, 3].
if not exist "W:\Windows\Setup\Scripts" mkdir "W:\Windows\Setup\Scripts"
(
echo @echo off
echo net user AdminUser /add /y
echo net localgroup "Administradores" AdminUser /add
echo net accounts /maxpwage:unlimited
) > W:\Windows\Setup\Scripts\SetupComplete.cmd [cite: 3]

:: 5. BOOTSTRAPPING
:: Configures UEFI boot manager and cleans temporary setup files[cite: 4].
bcdboot W:\Windows /s S: /f UEFI /l es-ES >nul [cite: 4]
rd /s /q "W:\Windows\Panther" 2>nul [cite: 4]

echo [+] Deployment process completed.
pause
exit