@ECHO off & SETLOCAL enabledelayedexpansion
REM https://github.com/nethe-GitHub/select_default_GPU
SET DisplayAdaptersClass="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
SET EnumPCILoaction="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\PCI"
SET DXLocation="HKEY_CURRENT_USER\Software\Microsoft\DirectX"
SET GLCompatibleLocation="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL"
SET GLOn12Location="HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\Microsoft.D3DMappingLayers_1.2302.1.0_x64__8wekyb3d8bbwe"

:Begin
ECHO.
ECHO 1-��ϵͳ��ʾ������ָ���Կ�
ECHO 2-ѡ��DirectXĬ�ϸ�����GPU
ECHO 3-ѡ��OpenGL���ص�ICD
ECHO 0-�˳�
SET /p FunctionSelect=����ѡ�� || GOTO :Begin
SET /a FunctionSelect=%FunctionSelect:~0,1% || GOTO :Begin
IF %FunctionSelect% EQU 1 (GOTO :Function1)
IF %FunctionSelect% EQU 2 (GOTO :Function2)
IF %FunctionSelect% EQU 3 (GOTO :Function3)
IF %FunctionSelect% EQU 0 (GOTO :End)
GOTO :Begin

:Function1
REM ������ʾ�����е�Ĭ�ϸ�����GPUѡ��
REG ADD %DXLocation%\GraphicsSettings /f /v DefaultHighPerfGPUApplicable /t REG_DWORD /d 1 >NUL
REM ������ʾ������ΪӦ��ѡ���ض�GPU
REG ADD %DXLocation%\GraphicsSettings /f /v SpecificGPUOptionApplicable /t REG_DWORD /d 1 >NUL
START "C:\Windows\ImmersiveControlPanel\SystemSettings.exe" "ms-settings:display-advancedgraphics"
GOTO :Begin

:Function2
SET /a DA.max=1
SET DA.did[0]=""
SET DA.reg[0]=""
SET DA.desc[0]=""
(FOR /f "usebackq" %%i IN (`REG QUERY %DisplayAdaptersClass% /f "00" /k`) DO (
	SET driver=%%i
	SET driver=!driver:~-43!
	(FOR /f "usebackq tokens=3" %%j IN (`REG QUERY %%i /v MatchingDeviceId`) DO (
		SET vendev=%%j
		SET vendev=!vendev:~0,21!
		SET pciloc=_
		(FOR /f "usebackq" %%k IN (`REG QUERY %EnumPCILoaction% /s /f !driver!`) DO (
			SET t=%%k
			ECHO !t:^&=^^^&! | FINDSTR /i !vendev! >NUL && SET pciloc=%%k
		))
		SET did=_
		(FOR /f "usebackq tokens=4,6,8 delims=_&" %%k IN ('!pciloc!') DO (
			SET did=%%k^&%%l^&%%m
		))
		ECHO !did! | FINDSTR /i /b _ >NUL || SET DA.did[!DA.max!]=!did!
	))
	IF DEFINED DA.did[!DA.max!] (
		SET DA.reg[!DA.max!]=%%i
		(FOR /f "usebackq skip=2 delims=" %%j IN (`REG QUERY %%i /v DriverDesc`) DO (
			SET t=%%j
			SET t=!t:REG_SZ    =,!
			(FOR /f "usebackq tokens=2 delims=," %%k IN ('!t!') DO (
				SET DA.desc[!DA.max!]=%%k
			))
		))
		SET /a DA.max=!DA.max!+1
	)
)) 2>NUL
SET /a DA.max=!DA.max!-1

ECHO �ҵ�������GPU��
(FOR /l %%i in (1,1,%DA.max%) DO (
	ECHO %%i. !DA.did[%%i]!	!DA.desc[%%i]!	!DA.reg[%%i]!
	ECHO.
))
SET /p DXSelect=����1~%DA.max%ѡ������0ȡ���� || GOTO :Function1
SET /a DXSelect=%DXSelect:~0,1% || GOTO :Function1
IF %DXSelect% EQU 0 (GOTO :Begin)
IF %DXSelect% GTR %DA.max% (GOTO :Function1)

SET Output=select_DX_!DA.desc[%DXSelect%]:~0,1!.bat
ECHO @ECHO off >%Output%
(	ECHO REM �Զ����ɵĽű������ڽ�DirectXĬ�ϸ������Կ���Ӳ��ID����Ϊ!DA.desc[%DXSelect%]!
	ECHO REG QUERY %DXLocation%\UserGpuPreferences /v DirectXUserGlobalSettings ^| FINDSTR "SwapEffectUpgradeEnable=1" ^>NUL ^&^& SET DXSettings=SwapEffectUpgradeEnable=1; ^|^| SET DXSettings=SwapEffectUpgradeEnable=0;
	ECHO SET DXSettings=HighPerfAdapter=!DA.did[%DXSelect%]:^&=^^^^^^^&!;%%DXSettings%%
	ECHO REG ADD %DXLocation%\UserGpuPreferences /f /v DirectXUserGlobalSettings /d %%DXSettings%%
) >>%Output%
ECHO �������������ļ�%cd%\%Output%

SET /p ApplySelect=�Ƿ���������%Output%��(Y/N)��
ECHO %ApplySelect% | FINDSTR /i /b y >NUL || GOTO :Begin
CALL %Output% && ECHO �޸ĳɹ���
GOTO :Begin

:Function3
(FOR /f "usebackq skip=2" %%i IN (`REG QUERY %GLOn12Location% /v SupportedUsers`) DO (
	ECHO ���棺��⵽ϵͳ�а�װ�ˡ�OpenCL?��OpenGL?���ݰ�������ж�غ�����Ч
)) 2>NUL

SET /a DA.max=1
SET DA.reg[0]=""
SET DA.desc[0]=""
SET DA.path[0]=""
SET DA.path32[0]=""
(FOR /f "usebackq" %%i IN (`REG QUERY %DisplayAdaptersClass% /f "00" /k`) DO (
	(FOR /f "usebackq tokens=3" %%j IN (`REG QUERY %%i /v OpenGLDriverName`) DO (
		SET DA.path[!DA.max!]=%%j
	))
	(FOR /f "usebackq tokens=3" %%j IN (`REG QUERY %%i /v OpenGLDriverNameWow`) DO (
		SET DA.path32[!DA.max!]=%%j
	))
	IF NOT DEFINED DA.path[!DA.max!] (
		(FOR /f "usebackq tokens=3" %%j IN (`REG QUERY %%i /v _OpenGLDriverName`) DO (
			SET DA.path[!DA.max!]=%%j
		))
		(FOR /f "usebackq tokens=3" %%j IN (`REG QUERY %%i /v _OpenGLDriverNameWow`) DO (
			SET DA.path32[!DA.max!]=%%j
		))
	)
	IF DEFINED DA.path[!DA.max!] (
		SET DA.reg[!DA.max!]=%%i
		(FOR /f "usebackq skip=2 delims=" %%j IN (`REG QUERY %%i /v DriverDesc`) DO (
			SET t=%%j
			SET t=!t:REG_SZ    =,!
			(FOR /f "usebackq tokens=2 delims=," %%k IN ('!t!') DO (
				SET DA.desc[!DA.max!]=%%k
			))
		))
		SET /a DA.max=!DA.max!+1
	)
)) 2>NUL
SET /a DA.max=!DA.max!-1

ECHO �ҵ�������OpenGL ICD:
(FOR /l %%i in (1,1,%DA.max%) DO (
	ECHO %%i. !DA.desc[%%i]!	!DA.reg[%%i]!	!DA.path[%%i]!	!DA.path32[%%i]!
	ECHO.
))
SET /p GLSelect=����1~%DA.max%ѡ������0ȡ���� || GOTO :Function2
SET /a GLSelect=%GLSelect:~0,1% || GOTO :Function2
IF %GLSelect% EQU 0 (GOTO :Begin)
IF %GLSelect% GTR %DA.max% (GOTO :Function2)

SET Output=select_GL_!DA.desc[%GLSelect%]:~0,1!.bat
ECHO @ECHO off >%Output%
(	ECHO REM �Զ����ɵĽű�������ʹϵͳѡ��!DA.desc[%GLSelect%]!��Ӧ��OpenGL ICD
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 ^|^| ECHO �޸�ʧ�ܣ���ʹ�ù���ԱȨ������%%~dp0%%%Output% ^&^& Pause ^&^& EXIT /b -1
	ECHO ^(REG ADD %GLCompatibleLocation% /f /reg:32
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 /v DLL /d !DA.path[%GLSelect%]!
	ECHO REG ADD %GLCompatibleLocation% /f /reg:32 /v DLL /d !DA.path32[%GLSelect%]!
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 /v DriverVersion /t REG_DWORD /d 1
	ECHO REG ADD %GLCompatibleLocation% /f /reg:32 /v DriverVersion /t REG_DWORD /d 1
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 /v Version /t REG_DWORD /d 2
	ECHO REG ADD %GLCompatibleLocation% /f /reg:32 /v Version /t REG_DWORD /d 2
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 /v Flags /t REG_DWORD /d 3
	ECHO REG ADD %GLCompatibleLocation% /f /reg:32 /v Flags /t REG_DWORD /d 3
	(FOR /l %%i in (1,1,%DA.max%) DO (
		ECHO REG ADD !DA.reg[%%i]! /f /v _OpenGLDriverName /d !DA.path[%%i]!
		ECHO REG ADD !DA.reg[%%i]! /f /v _OpenGLDriverNameWow /d !DA.path32[%%i]!
		ECHO REG DELETE !DA.reg[%%i]! /f /v OpenGLDriverName
		ECHO REG DELETE !DA.reg[%%i]! /f /v OpenGLDriverNameWow
	))
	ECHO ^) 2^>NUL
) >>%Output%
ECHO �������������ļ�%cd%\%Output%
ECHO ������״�ʹ�ã�������������Ч��

SET /p ApplySelect=�Ƿ���������%Output%������Ҫ����ԱȨ�ޣ�(Y/N)��
ECHO %ApplySelect% | FINDSTR /i /b y >NUL || GOTO :Begin
CALL %Output% && ECHO �޸ĳɹ���
GOTO :Begin

:End
ENDLOCAL
EXIT 0
