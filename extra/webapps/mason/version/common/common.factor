! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar io io.encodings.ascii io.launcher
kernel make mason.config namespaces ;
IN: webapps.mason.version.common

: execute-on-server ( string -- )
    [ "ssh" , package-host get , "-l" , package-username get , ] { } make
    <process>
        swap >>command
        5 minutes >>timeout
    ascii [ write ] with-process-writer ;
