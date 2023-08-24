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
    set _git_pull=1
    set _compile_vm=1
    set _bootimage_type=download
    set _bootstrap_factor=1
) else if "%1"=="latest" (
    set _git_pull=1
    set _compile_vm=1
    set _bootimage_type=download
    set _bootstrap_factor=1
) else if "%1"=="update" (
    set _git_pull=1
    set _compile_vm=1
    set _bootimage_type=download
    set _bootstrap_factor=1
) else if "%1"=="compile" (
    set _git_pull=0
    set _compile_vm=1
    set _bootimage_type=current
    set _bootstrap_factor=0
) else if "%1"=="self-bootstrap" (
    set _git_pull=1
    set _compile_vm=0
    set _bootimage_type=make
    set _bootstrap_factor=1
) else if "%1"=="bootstrap" (
    set _git_pull=0
    set _compile_vm=0
    set _bootimage_type=current
    set _bootstrap_factor=1
) else if "%1"=="net-bootstrap" (
    set _git_pull=0
    set _compile_vm=1
    set _bootimage_type=download
    set _bootstrap_factor=1
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

if "%_git_pull%"=="1" (
    echo Updating working copy from %GIT_BRANCH%...
    call git pull https://github.com/factor/factor %GIT_BRANCH%
    if errorlevel 1 goto fail
)

if "%_compile_vm%"=="1" (
    echo Building vm...
    nmake /nologo /f Nmakefile clean
    if errorlevel 1 goto fail

    nmake /nologo /f Nmakefile %_target%
    if errorlevel 1 goto fail
)

set _bootimage_url=https://downloads.factorcode.org/images/%GIT_BRANCH%/%_bootimage%
if "%_bootimage_type%"=="download" (
    echo Fetching %GIT_BRANCH% boot image...
    echo URL: %_bootimage_url%
    cscript /nologo misc\http-get.vbs %_bootimage_url% %_bootimage%
    if errorlevel 1 (
        echo boot image for branch %GIT_BRANCH% is not on server, trying master instead
        set "_bootimage_url="
        set "_bootimage_url=https://downloads.factorcode.org/images/master/%_bootimage%"
        echo URL: %_bootimage_url%
        cscript /nologo misc\http-get.vbs %_bootimage_url% %_bootimage%
        if errorlevel 1 goto fail
    )
) else if "%_bootimage_type%"=="make" (
    echo Making boot image...
    .\factor.com -run=bootstrap.image %_bootimage%
    if errorlevel 1 goto fail
)

if "%_bootstrap_factor%"=="1" (
    echo Bootstrapping...
    .\factor.com -i=%_bootimage%
    if errorlevel 1 goto fail

    echo Copying fresh factor.image to factor.image.fresh.
    copy factor.image factor.image.fresh
    if errorlevel 1 goto fail
)

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
echo Usage: build.cmd [command]
echo     Updates the working copy, cleans and builds the vm using nmake,
echo     fetches a boot image, and bootstraps factor.
echo:
echo     The branch that bootstraps is the one that is checked out locally.
echo:
echo     compile - recompile vm
echo     update - git pull, recompile vm, download a boot image, bootstrap
echo     self-bootstrap - git pull, make a boot image, bootstrap
echo     bootstrap - existing boot image, bootstrap
echo     net-bootstrap - recompile vm, download a boot image, bootstrap
goto :EOF
