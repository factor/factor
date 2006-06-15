! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: assembler errors io io-internals kernel math namespaces
parser threads words ;

: boot ( -- )
    #! Initialize an interpreter with the basic services.
    init-namespaces
    cell \ cell set
    millis init-random
    init-io
    "HOME" os-env [ "." ] unless* "~" set
    init-error-handler
    init-threads
    default-cli-args
    parse-command-line
    "null-stdio" get [ stdio off ] when ;
