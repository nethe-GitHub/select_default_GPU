@ECHO off 
REM 自动生成的脚本，用于使系统选择Radeon RX Vega M GH Graphics对应的OpenGL ICD
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:64 || ECHO 修改失败，须使用管理员权限运行%~dp0%select_GL_R.bat && Pause && EXIT /b -1
(REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:32
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:64 /v DLL /d C:\WINDOWS\System32\DriverStore\FileRepository\u0383042.inf_amd64_f8a5f7ffa245b1bb\B382319\atig6pxx.dll
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:32 /v DLL /d C:\WINDOWS\System32\DriverStore\FileRepository\u0383042.inf_amd64_f8a5f7ffa245b1bb\B382319\atiglpxx.dll
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:64 /v DriverVersion /t REG_DWORD /d 1
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:32 /v DriverVersion /t REG_DWORD /d 1
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:64 /v Version /t REG_DWORD /d 2
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:32 /v Version /t REG_DWORD /d 2
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:64 /v Flags /t REG_DWORD /d 3
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f /reg:32 /v Flags /t REG_DWORD /d 3
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000 /f /v _OpenGLDriverName /d C:\WINDOWS\System32\DriverStore\FileRepository\u0383042.inf_amd64_f8a5f7ffa245b1bb\B382319\atig6pxx.dll
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000 /f /v _OpenGLDriverNameWow /d C:\WINDOWS\System32\DriverStore\FileRepository\u0383042.inf_amd64_f8a5f7ffa245b1bb\B382319\atiglpxx.dll
REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000 /f /v OpenGLDriverName
REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000 /f /v OpenGLDriverNameWow
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001 /f /v _OpenGLDriverName /d C:\WINDOWS\System32\DriverStore\FileRepository\iigd_dch.inf_amd64_b53c057d22ce6f37\ig11icd64.dll
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001 /f /v _OpenGLDriverNameWow /d C:\WINDOWS\System32\DriverStore\FileRepository\iigd_dch.inf_amd64_b53c057d22ce6f37\ig11icd32.dll
REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001 /f /v OpenGLDriverName
REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001 /f /v OpenGLDriverNameWow
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0002 /f /v _OpenGLDriverName /d C:\WINDOWS\System32\DriverStore\FileRepository\nvacig.inf_amd64_853524551286f4d6\nvoglv64.dll
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0002 /f /v _OpenGLDriverNameWow /d C:\WINDOWS\System32\DriverStore\FileRepository\nvacig.inf_amd64_853524551286f4d6\nvoglv32.dll
REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0002 /f /v OpenGLDriverName
REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0002 /f /v OpenGLDriverNameWow
) 2>NUL
EXIT /b 0
