@ECHO off 
REM �Զ����ɵĽű������ڽ�DirectXĬ�ϸ������Կ���Ӳ��ID����ΪCYX-patch P102-100
REM ������ʾ�����е�Ĭ�ϸ�����GPUѡ��
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\GraphicsSettings /f /v DefaultHighPerfGPUApplicable /t REG_DWORD /d 1
REM ������ʾ������ΪӦ��ѡ���ض�GPU
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\GraphicsSettings /f /v SpecificGPUOptionApplicable /t REG_DWORD /d 1

REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\UserGpuPreferences /v DirectXUserGlobalSettings | FINDSTR "SwapEffectUpgradeEnable=1" >NUL && SET DXSettings=SwapEffectUpgradeEnable=1; || SET DXSettings=SwapEffectUpgradeEnable=0;
SET DXSettings=HighPerfAdapter=10DE^^^&1B07^^^&247419DA;%DXSettings%
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\DirectX"\UserGpuPreferences /f /v DirectXUserGlobalSettings /d %DXSettings%
EXIT /b 0
