! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: io-internals namespaces parser stdio threads words ;

: boot ( -- )
    #! Initialize an interpreter with the basic services.
    global >n
    init-threads
    init-c-io
    "HOME" os-env [ "." ] unless* "~" set
    init-search-path ;

"Good morning!" print
flush
"/library/bootstrap/boot-stage2.factor" run-resource
