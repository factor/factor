! Copyright (C) 2015 Dimage Sapelkin.
! See http://factorcode.org/license.txt for BSD license.
USING: editors kernel make math.parser namespaces sequences quotations system alien.data alien.strings 
       windows.advapi32 windows.registry windows.types windows.errors windows.registry.private combinators ;
IN: editors.brackets

SINGLETON: brackets-editor
brackets-editor \ editor-class set-global

! SYMBOL: brackets-path

! HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Brackets.exe

<PRIVATE

: windows-get-brackets-path ( -- path )
    HKEY_LOCAL_MACHINE "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\Brackets.exe" KEY_READ
    [ f f f registry-value-max-length TCHAR <c-array> reg-query-value-ex ] with-open-registry-key
    alien>native-string
;

PRIVATE>

M: brackets-editor editor-command ( file line -- command )
    [ os { 
         { [ dup windows? ] ! only windows implemented so far, though Brackets is a cross-platform app
           [ drop windows-get-brackets-path ] }
         { [ t ] [ drop "brackets" ] }
      } cond
      ,
      drop ,
    ] { } make ;

