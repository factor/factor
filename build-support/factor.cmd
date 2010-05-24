@echo off
if not exist Nmakefile goto wrong_dir

if /i %PROCESSOR_ARCHITECTURE%==AMD64 (
    set _target="x86-64"
    set _bootimage="boot.winnt-x86.64.image"
) else (
    set _target="x86-32"
    set _bootimage="boot.winnt-x86.32.image"
)

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
cmd /c "git pull http://factorcode.org/git/factor.git %_git_branch%"
if not errorlevel 0 goto fail

echo Building vm...
nmake /nologo /f Nmakefile clean
if not errorlevel 0 goto fail
nmake /nologo /f Nmakefile %_target%
if not errorlevel 0 goto fail

echo Fetching %_bootimage_version% boot image...
cscript /nologo build-support\http-get.vbs http://factorcode.org/images/%_bootimage_version%/%_bootimage% %_bootimage%
if not errorlevel 0 goto fail

echo Bootstrapping...
.\factor.com -i=%_bootimage%
if not errorlevel 0 goto fail

echo Build complete.
goto cleanup

:fail
echo Build failed.
goto cleanup

:wrong_dir
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
