USING: io.backend kernel ;
IN: io.priority

HOOK: get-priority io-backend ( -- n )
HOOK: set-priority io-backend ( n -- )
