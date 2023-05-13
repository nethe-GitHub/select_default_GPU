@ECHO off & SETLOCAL enabledelayedexpansion
REM https://github.com/nethe-GitHub/select_default_GPU
SET DisplayAdaptersClass="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
SET EnumPCILoaction="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\PCI"
SET DXLocation="HKEY_CURRENT_USER\Software\Microsoft\DirectX"
SET GLCompatibleLocation="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL"
SET GLOn12Location="HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\Microsoft.D3DMappingLayers_1.2302.1.0_x64__8wekyb3d8bbwe"

:Begin
ECHO.
ECHO 1-select default high-perf GPU for DirectX
ECHO 2-select the ICD loaded by OpenGL
ECHO 0-exit
SET /p FunctionSelect=choose a function£º || GOTO :Begin
SET /a FunctionSelect=%FunctionSelect:~0,1% || GOTO :Begin
IF %FunctionSelect% EQU 1 (GOTO :Function1)
IF %FunctionSelect% EQU 2 (GOTO :Function2)
IF %FunctionSelect% EQU 0 (GOTO :End)
GOTO :Begin

:Function1
SET /a DA.max=1
SET DA.did[0]=""
SET DA.reg[0]=""
SET DA.desc[0]=""
(FOR /f "usebackq" %%i IN (`REG QUERY %DisplayAdaptersClass% /f "00" /k`) DO (
	(FOR /f "usebackq tokens=3" %%j IN (`REG QUERY %%i /v MatchingDeviceId`) DO (
		SET pciloc=%%j
		SET pciloc=!pciloc:^&=^^^&!
		(FOR /f "usebackq" %%k IN (`REG QUERY %EnumPCILoaction% /f !pciloc:~4!`) DO (
			ECHO %%k | findstr /b %EnumPCILoaction% >NUL && SET pciloc=%%k
		))
		SET t=_
		(FOR /f "usebackq tokens=4,6,8 delims=_&" %%k IN ('!pciloc!') DO (
			SET t=%%k^&%%l^&%%m
		))
		ECHO !t! | FINDSTR /i /b _ >NUL || SET DA.did[!DA.max!]=!t!
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

ECHO Found the following GPUs£º
(FOR /l %%i in (1,1,%DA.max%) DO (
	ECHO %%i. !DA.desc[%%i]!	!DA.reg[%%i]!	!DA.did[%%i]!
	ECHO.
))
SET /p DXSelect=Input 1~%DA.max% to choose, 0 to cancel: || GOTO :Function1
SET /a DXSelect=%DXSelect:~0,1% || GOTO :Function1
IF %DXSelect% EQU 0 (GOTO :Begin)
IF %DXSelect% GTR %DA.max% (GOTO :Function1)

SET Output=select_DX_!DA.desc[%DXSelect%]:~0,1!.bat
ECHO @ECHO off >%Output%
(	ECHO REM Program generated batch file, aim to set !DA.desc[%DXSelect%]! as default high-perf DirectX GPU
	ECHO REM Allows to choose default high performance GPU in system settings
	ECHO REG ADD %DXLocation%\GraphicsSettings /f /v DefaultHighPerfGPUApplicable /t REG_DWORD /d 1
	ECHO REM Allows to choose specific GPU for programs in system settings
	ECHO REG ADD %DXLocation%\GraphicsSettings /f /v SpecificGPUOptionApplicable /t REG_DWORD /d 1
	ECHO.
	ECHO REG QUERY %DXLocation%\UserGpuPreferences /v DirectXUserGlobalSettings ^| FINDSTR "SwapEffectUpgradeEnable=1" ^>NUL ^&^& SET DXSettings=SwapEffectUpgradeEnable=1; ^|^| SET DXSettings=SwapEffectUpgradeEnable=0;
	ECHO SET DXSettings=HighPerfAdapter=!DA.did[%DXSelect%]:^&=^^^^^^^&!;%%DXSettings%%
	ECHO REG ADD %DXLocation%\UserGpuPreferences /f /v DirectXUserGlobalSettings /d %%DXSettings%%
	ECHO EXIT /b 0
) >>%Output%
ECHO Batch file %cd%\%Output% generated.

SET /p ApplySelect=Run %Output% now?(Y/N)£º
ECHO %ApplySelect% | FINDSTR /i /b y >NUL || GOTO :Begin
CALL %Output% && ECHO Success.
GOTO :Begin

:Function2
(FOR /f "usebackq skip=2" %%i IN (`REG QUERY %GLOn12Location% /v SupportedUsers`) DO (
	ECHO Warning: OpenCL? and OpenGL? Compatibility Pack is installed. It must be removed to take effect.
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

ECHO Found the following OpenGL ICDs:
(FOR /l %%i in (1,1,%DA.max%) DO (
	ECHO %%i. !DA.desc[%%i]!	!DA.reg[%%i]!	!DA.path[%%i]!	!DA.path32[%%i]!
	ECHO.
))
SET /p GLSelect=Input 1~%DA.max% to choose, 0 to cancel: || GOTO :Function2
SET /a GLSelect=%GLSelect:~0,1% || GOTO :Function2
IF %GLSelect% EQU 0 (GOTO :Begin)
IF %GLSelect% GTR %DA.max% (GOTO :Function2)

SET Output=select_GL_!DA.desc[%GLSelect%]:~0,1!.bat
ECHO @ECHO off >%Output%
(	ECHO REM Program generated batch file, aim to make the system use OpenGL ICD of !DA.desc[%DXSelect%]!
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 ^|^| ECHO Failed, must run %%~dp0%%%Output% as admin. ^&^& Pause ^&^& EXIT /b -1
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
	ECHO EXIT /b 0
) >>%Output%
ECHO Batch file %cd%\%Output% generated.
ECHO Reboot is required at first use.

SET /p ApplySelect=Run %Output% now? (Admin privilege is needed)(Y/N)£º
ECHO %ApplySelect% | FINDSTR /i /b y >NUL || GOTO :Begin
CALL %Output% && ECHO Success.
GOTO :Begin

:End
ENDLOCAL
EXIT 0
