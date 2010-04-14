! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar io io.encodings.ascii io.launcher
kernel make mason.config namespaces ;
IN: mason.version.common

: execute-on-server ( string -- )
    [ "ssh" , upload-host get , "-l" , upload-username get , ] { } make
    <process>
        swap >>command
        5 minutes >>timeout
    ascii [ write ] with-process-writer ;
