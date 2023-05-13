@ECHO off 
REM 自动生成的脚本，用于将DirectX默认高性能显卡的硬件ID设置为CYX-patch P102-100
REM 开启显示设置中的默认高性能GPU选项
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\GraphicsSettings /f /v DefaultHighPerfGPUApplicable /t REG_DWORD /d 1
REM 开启显示设置中为应用选择特定GPU
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\GraphicsSettings /f /v SpecificGPUOptionApplicable /t REG_DWORD /d 1

REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\UserGpuPreferences /v DirectXUserGlobalSettings | FINDSTR "SwapEffectUpgradeEnable=1" >NUL && SET DXSettings=SwapEffectUpgradeEnable=1; || SET DXSettings=SwapEffectUpgradeEnable=0;
SET DXSettings=HighPerfAdapter=10DE^^^&1B07^^^&247419DA;%DXSettings%
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\UserGpuPreferences /f /v DirectXUserGlobalSettings /d %DXSettings%
EXIT /b 0
