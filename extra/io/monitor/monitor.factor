! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations ;
IN: io.monitor

HOOK: <monitor> io-backend ( path recursive? -- monitor )

HOOK: next-change io-backend ( monitor -- path changes )

SYMBOL: +change-file+
SYMBOL: +change-name+
SYMBOL: +change-size+
SYMBOL: +change-attributes+
SYMBOL: +change-modified+

: with-monitor ( path recursive? quot -- )
    >r <monitor> r> with-disposal ; inline
