! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: assembler command-line errors io io-internals kernel math
namespaces parser words threads ;

: boot ( -- )
    init-namespaces
    cell \ cell set
    millis init-random
    init-io
    init-error-handler
    init-threads
    default-cli-args
    parse-command-line
    "null-stdio" get [ stdio off ] when ;
