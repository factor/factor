USING: assoc-heaps assocs calendar crypto.sha2 heaps
init kernel math.parser namespaces random ;
IN: furnace.sessions

SYMBOL: sessions

[
    H{ } clone <min-heap> <assoc-heap>
    sessions set-global
] "furnace.sessions" add-init-hook

: new-session-id ( -- str )
    4 big-random number>string string>sha-256-string
    dup sessions get-global at [ drop new-session-id ] when ;

TUPLE: session created last-seen user-agent namespace ;

M: session <=> ( session1 session2 -- n )
    [ session-last-seen ] 2apply <=> ;

: <session> ( -- obj )
    now dup H{ } clone
    [ set-session-created set-session-last-seen set-session-namespace ]
    \ session construct ;

: new-session ( -- obj id )
    <session> new-session-id [ sessions get-global set-at ] 2keep ;

: get-session ( id -- obj/f )
    sessions get-global at* [ "no session found 1" throw ] unless ;

! Delete from the assoc only, the heap will timeout
: destroy-session ( id -- )
    sessions get-global assoc-heap-assoc delete-at ;

: session> ( str -- obj )
    session get session-namespace at ;

: >session ( value key -- )
    session get session-namespace set-at ;
