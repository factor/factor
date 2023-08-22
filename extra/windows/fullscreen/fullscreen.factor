! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data classes.struct
endian kernel literals make math math.bitwise
sequences slots.syntax ui.backend.windows ui.gadgets.worlds
windows.errors windows.gdi32 windows.shcore windows.types
windows.user32 ;
IN: windows.fullscreen

: hwnd>hmonitor ( HWND -- HMONITOR )
    MONITOR_DEFAULTTOPRIMARY MonitorFromWindow ;

: desktop-hmonitor ( -- HMONITOR )
    GetDesktopWindow hwnd>hmonitor ;

:: (monitor-info>devmodes) ( monitor-info n -- )
    DEVMODE new
        DEVMODE heap-size >>dmSize
        flags{ DM_BITSPERPEL DM_PELSWIDTH DM_PELSHEIGHT } >>dmFields
    :> devmode

    monitor-info szDevice>>
    n
    devmode
    EnumDisplaySettings 0 = [
        devmode ,
        monitor-info n 1 + (monitor-info>devmodes)
    ] unless ;

: monitor-info>devmodes ( monito-info -- devmodes )
    [ 0 (monitor-info>devmodes) ] { } make ;

: hmonitor>monitor-info ( HMONITOR -- monitor-info )
    MONITORINFOEX new
        MONITORINFOEX heap-size >>cbSize
    [ GetMonitorInfo win32-error=0/f ] keep ;

: hwnd>monitor-info ( HWND -- monitor-info )
    hwnd>hmonitor hmonitor>monitor-info ;

: hmonitor>devmodes ( HMONITOR -- devmodes )
    hmonitor>monitor-info monitor-info>devmodes ;

: desktop-devmodes ( -- DEVMODEs )
    desktop-hmonitor hmonitor>devmodes ;

: desktop-monitor-info ( -- monitor-info )
    desktop-hmonitor hmonitor>monitor-info ;

: desktop-RECT ( -- RECT )
    GetDesktopWindow RECT new [ GetWindowRect win32-error=0/f ] keep ;

ERROR: display-change-error n ;

: fullscreen-mode ( monitor-info devmode -- )
    [ szDevice>> ] dip f CDS_FULLSCREEN f
    ChangeDisplaySettingsEx dup DISP_CHANGE_SUCCESSFUL =
    [ drop ] [ display-change-error ] if ;

: non-fullscreen-mode ( monitor-info devmode -- )
    [ szDevice>> ] dip f 0 f
    ChangeDisplaySettingsEx dup DISP_CHANGE_SUCCESSFUL =
    [ drop ] [ display-change-error ] if ;

: get-style ( hwnd n -- style )
    GetWindowLongPtr [ win32-error=0/f ] keep ;

: set-style ( hwnd n style -- )
    SetWindowLongPtr win32-error=0/f ;

: change-style ( hwnd n quot -- )
    [ 2dup get-style ] dip call set-style ; inline

: set-fullscreen-styles ( hwnd -- )
    [ GWL_STYLE [ WS_OVERLAPPEDWINDOW unmask ] change-style ]
    [ GWL_EXSTYLE [ flags{ WS_EX_APPWINDOW WS_EX_TOPMOST } bitor ] change-style ] bi ;

: set-non-fullscreen-styles ( hwnd -- )
    [ GWL_STYLE [ WS_OVERLAPPEDWINDOW bitor ] change-style ]
    [ GWL_EXSTYLE [ flags{ WS_EX_APPWINDOW WS_EX_TOPMOST } unmask ] change-style ] bi ;

ERROR: unsupported-resolution triple ;

:: find-devmode ( triple hwnd -- devmode )
    hwnd hwnd>hmonitor hmonitor>devmodes
    [
        slots{ dmPelsWidth dmPelsHeight dmBitsPerPel }
        triple =
    ] find nip [ triple unsupported-resolution ] unless* ;

:: set-fullscreen-window-position ( hwnd triple -- )
    hwnd f
    desktop-monitor-info rcMonitor>> slots{ left top } first2
    triple first2
    flags{
        SWP_NOACTIVATE SWP_NOCOPYBITS SWP_NOOWNERZORDER
        SWP_NOREPOSITION SWP_NOZORDER
    }
    SetWindowPos win32-error=0/f ;

:: enable-fullscreen ( triple hwnd -- rect )
    hwnd hwnd>RECT :> rect

    desktop-monitor-info
    triple GetDesktopWindow find-devmode
    hwnd set-fullscreen-styles
    fullscreen-mode

    hwnd triple set-fullscreen-window-position
    rect ;

:: set-window-position ( hwnd rect -- )
    hwnd f rect get-RECT-dimensions SWP_FRAMECHANGED
    SetWindowPos win32-error=0/f ;

:: disable-fullscreen ( rect triple hwnd -- )
    desktop-monitor-info
    triple
    GetDesktopWindow find-devmode non-fullscreen-mode
    hwnd set-non-fullscreen-styles
    hwnd rect set-window-position ;

: enable-factor-fullscreen ( triple -- rect )
    GetForegroundWindow enable-fullscreen ;

: disable-factor-fullscreen ( rect triple -- )
    GetForegroundWindow disable-fullscreen ;

:: (set-fullscreen) ( world triple fullscreen? -- )
    world fullscreen?>> fullscreen? xor [
        triple
        world handle>> hWnd>>
        fullscreen? [
            enable-fullscreen world saved-position<<
        ] [
            [ world saved-position>> ] 2dip disable-fullscreen
        ] if
        fullscreen? world fullscreen?<<
    ] when ;

: set-fullscreen ( gadget triple fullscreen? -- )
    [ find-world ] 2dip (set-fullscreen) ;

: get-desktop-scale-factor ( -- n )
    desktop-hmonitor 0 DEVICE_SCALE_FACTOR <ref>
    [ GetScaleFactorForMonitor win32-error=0/f ] keep le> ;
