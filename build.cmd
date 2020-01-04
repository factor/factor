@echo off
setlocal

: Check which branch we are on, or just assume master if we are not in a git repository
for /f %%z in ('git rev-parse --abbrev-ref HEAD') do set GIT_BRANCH=%%z
if not defined GIT_BRANCH (
    set GIT_BRANCH=master
)

if "%1"=="/?" (
    goto usage
) else if "%1"=="" (
    set _bootimage_version=%GIT_BRANCH%
) else if "%1"=="latest" (
    set _bootimage_version=%GIT_BRANCH%
) else if "%1"=="update" (
    set _bootimage_version=%GIT_BRANCH%
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

echo Deleting staging images from temp/...
del temp\staging.*.image

echo Updating working copy from %GIT_BRANCH%...
call git pull git://factorcode.org/git/factor.git %GIT_BRANCH%
if errorlevel 1 goto fail

echo Building vm...
nmake /nologo /f Nmakefile clean
if errorlevel 1 goto fail

nmake /nologo /f Nmakefile %_target%
if errorlevel 1 goto fail

echo Fetching %_bootimage_version% boot image...
set boot_image_url=http://downloads.factorcode.org/images/%GIT_BRANCH%/%_bootimage% %_bootimage%
echo URL: %boot_image_url%
cscript /nologo misc\http-get.vbs %boot_image_url% %_bootimage%
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
echo build.cmd must be run from the root of the Factor source tree.
goto :EOF

:nocl
echo Unable to detect cl.exe target platform.
echo Make sure you're running within the Visual Studio or Windows SDK environment.
goto :EOF

:usage
echo Usage: build.cmd
echo     Updates the working copy, cleans and builds the vm using nmake,
echo     fetches a boot image, and bootstraps factor.
echo     The branch that bootstraps is the one that is checked out locally.
goto :EOF
