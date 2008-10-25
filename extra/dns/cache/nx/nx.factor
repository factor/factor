
USING: kernel assocs locals combinators
       math math.functions system unicode.case ;

IN: dns.cache.nx

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: nx-cache ( -- table ) H{ } ;

: nx-cache-at        (      name -- time ) >lower nx-cache at        ;
: nx-cache-delete-at (      name --      ) >lower nx-cache delete-at ;
: nx-cache-set-at    ( time name --      ) >lower nx-cache set-at    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: now ( -- seconds ) millis 1000.0 / round >integer ;

:: non-existent-name? ( NAME -- ? )
   [let | TIME [ NAME nx-cache-at ] |
     {
       { [ TIME f    = ] [                         f ] }
       { [ TIME now <= ] [ NAME nx-cache-delete-at f ] }
       { [ t           ] [                         t ] }
     }
     cond
   ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: cache-non-existent-name ( NAME TTL -- )
   [let | TIME [ TTL now + ] | TIME NAME nx-cache-set-at ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

