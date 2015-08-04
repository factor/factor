@echo off
setlocal

if "%1"=="/?" (
    goto usage
) else if "%1"=="" (
    set _bootimage_version=latest
) else if "%1"=="latest" (
    set _bootimage_version=latest
) else if "%1"=="clean" (
    set _bootimage_version=clean
) else goto usage

if not exist Nmakefile goto wrongdir

call cl 2>&1 | find "x86" >nul
if not errorlevel 1 (
    echo x86-32 cl.exe detected.
    set _target=x86-32
    set _bootimage=boot.windows-x86.32.image
) else (
    call cl 2>&1 | find "x64" >nul
    if not errorlevel 1 (
        echo x86-64 cl.exe detected.
        set _target=x86-64
        set _bootimage=boot.windows-x86.64.image
    ) else goto nocl
)

: Fun syntax
for /f %%x in ('git describe --all') do set GIT_DESCRIBE=%%x
for /f %%y in ('git rev-parse HEAD') do call set GIT_ID=%%y

set git_label=%GIT_DESCRIBE%-%GIT_ID%
set version=0.98

if %_bootimage_version%==clean (
    set _git_branch=clean-windows-%_target%
    set _bootimage_path=clean/windows-%_target%
) else (
    set _git_branch=master
    set _bootimage_path=latest
)

echo Deleting staging images from temp/...
del temp\staging.*.image

echo Updating working copy from %_git_branch%...
call git pull http://factorcode.org/git/factor.git %_git_branch%
if errorlevel 1 goto fail

echo Building vm...
nmake /nologo /f Nmakefile clean
if errorlevel 1 goto fail
nmake /nologo /f Nmakefile %_target%
if errorlevel 1 goto fail

echo Fetching %_bootimage_version% boot image...
cscript /nologo build-support\http-get.vbs http://downloads.factorcode.org/images/%_bootimage_path%/%_bootimage% %_bootimage%
if errorlevel 1 goto fail

echo Bootstrapping...
.\factor.com -i=%_bootimage%
if errorlevel 1 goto fail

echo Copying fresh factor.image to factor.image.fresh.
copy factor.image factor.image.fresh
if errorlevel 1 goto fail

echo Build complete.
goto :EOF

:fail
echo Build failed.
goto :EOF

:wrongdir
echo build-support\factor.cmd must be run from the root of the Factor source tree.
goto :EOF

:nocl
echo Unable to detect cl.exe target platform.
echo Make sure you're running within the Visual Studio or Windows SDK environment.
goto :EOF

:usage
echo Usage: build-support\factor.cmd [latest/clean]
echo     Updates the working copy, cleans and builds the vm using nmake,
echo     fetches a boot image, and bootstraps factor.
echo     If latest is specified, then the working copy is updated to the
echo     upstream "master" branch and the boot image corresponding to the
echo     most recent factor build is downloaded. This is the default.
echo     If clean is specified, then the working copy is updated to the
echo     upstream "clean-windows-*" branch corresponding to the current
echo     platform and the corresponding boot image is downloaded.
goto :EOF
