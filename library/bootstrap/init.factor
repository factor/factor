! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: assembler errors io io-internals kernel math namespaces
parser threads words ;

: boot ( -- )
    #! Initialize an interpreter with the basic services.
    global >n
    millis init-random
    init-threads
    init-io
    "HOME" os-env [ "." ] unless* "~" set
    init-assembler
    init-error-handler
    default-cli-args
    parse-command-line
    "null-stdio" get [ << null-stream f >> stdio set ] when ;
