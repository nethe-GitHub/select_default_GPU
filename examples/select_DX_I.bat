@ECHO off 
REM Program generated batch file, aim to set Intel(R) HD Graphics 630 as default high-perf DirectX GPU
REM Allows to choose default high performance GPU in system settings
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\GraphicsSettings /f /v DefaultHighPerfGPUApplicable /t REG_DWORD /d 1
REM Allows to choose specific GPU for programs in system settings
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\GraphicsSettings /f /v SpecificGPUOptionApplicable /t REG_DWORD /d 1

REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\UserGpuPreferences /v DirectXUserGlobalSettings | FINDSTR "SwapEffectUpgradeEnable=1" >NUL && SET DXSettings=SwapEffectUpgradeEnable=1; || SET DXSettings=SwapEffectUpgradeEnable=0;
SET DXSettings=HighPerfAdapter=8086^^^&591B^^^&20738086;%DXSettings%
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\UserGpuPreferences /f /v DirectXUserGlobalSettings /d %DXSettings%
EXIT /b 0
