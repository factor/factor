! Copyright (C) 2015 Dimage Sapelkin.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.data alien.strings combinators editors
editors.brackets kernel make math.parser namespaces quotations
sequences system windows.advapi32 windows.registry
windows.registry.private windows.types windows.errors ;

IN: editors.brackets.windows

M: windows brackets-path
    HKEY_LOCAL_MACHINE
    "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\Brackets.exe"
    KEY_READ [
        f f f
        registry-value-max-length TCHAR <c-array>
        reg-query-value-ex
    ] with-open-registry-key alien>native-string ;
