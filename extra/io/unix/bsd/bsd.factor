! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.bsd
USING: io.backend io.unix.backend io.unix.select
namespaces system ;

M: bsd init-io ( -- )
    <select-mx> mx set-global ;
