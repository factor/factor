@echo off
if not exist Nmakefile goto wrongdir

call cl 2>&1 | find "x86" >nul
if not errorlevel 1 goto cl32

call cl 2>&1 | find "x64" >nul
if not errorlevel 1 goto cl64

goto nocl

:cl32
echo x86-32 cl.exe detected.
set _target="x86-32"
set _bootimage="boot.winnt-x86.32.image"
goto platformdefined

:cl64
echo x86-64 cl.exe detected.
set _target="x86-64"
set _bootimage="boot.winnt-x86.64.image"
goto platformdefined

:nocl
echo Unable to detect cl.exe target platform.
echo Make sure you're running within the Visual Studio or Windows SDK environment.
goto cleanup

:platformdefined

if "%1"=="/?" goto usage

if "%1"=="" (
    set _bootimage_version="latest"
    set _git_branch=master
)
if "%1"=="latest" (
    set _bootimage_version="latest"
    set _git_branch=master
)
if "%1"=="clean" (
    set _bootimage_version="clean"
    set _git_branch=clean-winnt-%_target%
)

if not defined _bootimage_version goto usage

echo Updating working copy...
call git pull http://factorcode.org/git/factor.git %_git_branch%
if errorlevel 1 goto fail

echo Building vm...
nmake /nologo /f Nmakefile clean
if errorlevel 1 goto fail
nmake /nologo /f Nmakefile %_target%
if errorlevel 1 goto fail

echo Fetching %_bootimage_version% boot image...
cscript /nologo build-support\http-get.vbs http://factorcode.org/images/%_bootimage_version%/%_bootimage% %_bootimage%
if errorlevel 1 goto fail

echo Bootstrapping...
.\factor.com -i=%_bootimage%
if errorlevel 1 goto fail

echo Copying fresh factor.image to factor.image.fresh
copy factor.image factor.image.fresh
if errorlevel 1 goto fail

echo Build complete.
goto cleanup

:fail
echo Build failed.
goto cleanup

:wrongdir
echo build-support\factor.cmd must be run from the root of the Factor source tree.
goto cleanup

:usage
echo Usage: build-support\factor.cmd [latest/clean]
echo     Updates the working copy, cleans and builds the vm using nmake,
echo     fetches a boot image, and bootstraps factor.
echo     If latest is specified, then the working copy is updated to the
echo     upstream "master" branch and the boot image corresponding to the
echo     most recent factor build is downloaded. This is the default.
echo     If clean is specified, then the working copy is updated to the
echo     upstream "clean-winnt-*" branch corresponding to the current
echo     platform and the corresponding boot image is downloaded.
goto cleanup

:cleanup
set _target=
set _bootimage=
set _bootimage_version=
set _git_branch=
