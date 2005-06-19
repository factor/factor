! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: io-internals namespaces parser io threads words ;

: boot ( -- )
    #! Initialize an interpreter with the basic services.
    global >n
    init-threads
    init-io
    "HOME" os-env [ "." ] unless* "~" set
    init-search-path ;
