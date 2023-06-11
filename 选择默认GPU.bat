@ECHO off & SETLOCAL enabledelayedexpansion
REM https://github.com/nethe-GitHub/select_default_GPU
SET DisplayAdaptersClass="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
SET EnumPCILoaction="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\PCI"
SET DXLocation="HKEY_CURRENT_USER\Software\Microsoft\DirectX"
SET GLCompatibleLocation="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL"
SET GLOn12Location="HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\Microsoft.D3DMappingLayers_1.2302.1.0_x64__8wekyb3d8bbwe"

:Begin
ECHO.
ECHO 1-打开系统显示设置以指定显卡
ECHO 2-选择DirectX默认高性能GPU
ECHO 3-选择OpenGL加载的ICD
ECHO 0-退出
SET /p FunctionSelect=功能选择： || GOTO :Begin
SET /a FunctionSelect=%FunctionSelect:~0,1% || GOTO :Begin
IF %FunctionSelect% EQU 1 (GOTO :Function1)
IF %FunctionSelect% EQU 2 (GOTO :Function2)
IF %FunctionSelect% EQU 3 (GOTO :Function3)
IF %FunctionSelect% EQU 0 (GOTO :End)
GOTO :Begin

:Function1
REM 开启显示设置中的默认高性能GPU选项
REG ADD %DXLocation%\GraphicsSettings /f /v DefaultHighPerfGPUApplicable /t REG_DWORD /d 1 >NUL
REM 开启显示设置中为应用选择特定GPU
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

ECHO 找到了以下GPU：
(FOR /l %%i in (1,1,%DA.max%) DO (
	ECHO %%i. !DA.did[%%i]!	!DA.desc[%%i]!	!DA.reg[%%i]!
	ECHO.
))
SET /p DXSelect=输入1~%DA.max%选择，输入0取消： || GOTO :Function1
SET /a DXSelect=%DXSelect:~0,1% || GOTO :Function1
IF %DXSelect% EQU 0 (GOTO :Begin)
IF %DXSelect% GTR %DA.max% (GOTO :Function1)

SET Output=select_DX_!DA.desc[%DXSelect%]:~0,1!.bat
ECHO @ECHO off >%Output%
(	ECHO REM 自动生成的脚本，用于将DirectX默认高性能显卡的硬件ID设置为!DA.desc[%DXSelect%]!
	ECHO REG QUERY %DXLocation%\UserGpuPreferences /v DirectXUserGlobalSettings ^| FINDSTR "SwapEffectUpgradeEnable=1" ^>NUL ^&^& SET DXSettings=SwapEffectUpgradeEnable=1; ^|^| SET DXSettings=SwapEffectUpgradeEnable=0;
	ECHO SET DXSettings=HighPerfAdapter=!DA.did[%DXSelect%]:^&=^^^^^^^&!;%%DXSettings%%
	ECHO REG ADD %DXLocation%\UserGpuPreferences /f /v DirectXUserGlobalSettings /d %%DXSettings%%
) >>%Output%
ECHO 已生成批处理文件%cd%\%Output%

SET /p ApplySelect=是否立即运行%Output%？(Y/N)：
ECHO %ApplySelect% | FINDSTR /i /b y >NUL || GOTO :Begin
CALL %Output% && ECHO 修改成功。
GOTO :Begin

:Function3
(FOR /f "usebackq skip=2" %%i IN (`REG QUERY %GLOn12Location% /v SupportedUsers`) DO (
	ECHO 警告：检测到系统中安装了《OpenCL?和OpenGL?兼容包》，需卸载后方能生效
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

ECHO 找到了以下OpenGL ICD:
(FOR /l %%i in (1,1,%DA.max%) DO (
	ECHO %%i. !DA.desc[%%i]!	!DA.reg[%%i]!	!DA.path[%%i]!	!DA.path32[%%i]!
	ECHO.
))
SET /p GLSelect=输入1~%DA.max%选择，输入0取消： || GOTO :Function2
SET /a GLSelect=%GLSelect:~0,1% || GOTO :Function2
IF %GLSelect% EQU 0 (GOTO :Begin)
IF %GLSelect% GTR %DA.max% (GOTO :Function2)

SET Output=select_GL_!DA.desc[%GLSelect%]:~0,1!.bat
ECHO @ECHO off >%Output%
(	ECHO REM 自动生成的脚本，用于使系统选择!DA.desc[%GLSelect%]!对应的OpenGL ICD
	ECHO REG ADD %GLCompatibleLocation% /f /reg:64 ^|^| ECHO 修改失败，须使用管理员权限运行%%~dp0%%%Output% ^&^& Pause ^&^& EXIT /b -1
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
ECHO 已生成批处理文件%cd%\%Output%
ECHO 如果是首次使用，需在重启后生效。

SET /p ApplySelect=是否立即运行%Output%？（需要管理员权限）(Y/N)：
ECHO %ApplySelect% | FINDSTR /i /b y >NUL || GOTO :Begin
CALL %Output% && ECHO 修改成功。
GOTO :Begin

:End
ENDLOCAL
EXIT 0
