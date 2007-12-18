USING: assocs calendar init kernel math.parser namespaces random ;
IN: furnace.sessions

SYMBOL: sessions

[ H{ } clone sessions set-global ] "furnace.sessions" add-init-hook

: new-session-id ( -- str )
    1 big-random number>string ;

TUPLE: session created last-seen user-agent namespace ;

: <session> ( -- obj )
    now dup H{ } clone
    [ set-session-created set-session-last-seen set-session-namespace ]
    \ session construct ;

: new-session ( -- obj id )
    <session> new-session-id [ sessions get-global set-at ] 2keep ;

: get-session ( id -- obj/f )
    sessions get-global at* [ "no session found 1" throw ] unless ;

: destroy-session ( id -- )
    sessions get-global delete-at ;

: session> ( str -- obj )
    session get session-namespace at ;

: >session ( value key -- )
    session get session-namespace set-at ;
