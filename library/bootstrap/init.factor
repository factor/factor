! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: assembler command-line errors io io-internals namespaces
parser threads words ;

: boot ( -- )
    #! Initialize an interpreter with the basic services.
    global >n
    init-threads
    init-io
    "HOME" os-env [ "." ] unless* "~" set
    init-search-path
    init-assembler
    init-error-handler
    default-cli-args
    parse-command-line
    "null-stdio" get [ << null-stream f >> stdio set ] when ;
