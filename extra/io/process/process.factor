USING: io.backend kernel ;
IN: io.priority

SYMBOL: +lowest-priority+
SYMBOL: +low-priority+
SYMBOL: +normal-priority+
SYMBOL: +high-priority+
SYMBOL: +highest-priority+

HOOK: current-priority io-backend ( -- symbol )
HOOK: set-current-priority io-backend ( symbol -- )
HOOK: priority-values ( -- assoc )

: lookup-priority ( symbol -- n )
    priority-values at ;

HOOK: get-process-list io-backend ( -- assoc )
