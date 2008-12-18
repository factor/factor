! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: xmode.marker.context xmode.rules accessors
xmode.tokens namespaces make kernel sequences assocs math ;
IN: xmode.marker.state

! Based on org.gjt.sp.jedit.syntax.TokenMarker

SYMBOLS: line last-offset position context
 whitespace-end seen-whitespace-end?
 escaped?  process-escape?  delegate-end-escaped? ;

: current-rule ( -- rule )
    context get in-rule>> ;

: current-rule-set ( -- rule )
    context get in-rule-set>> ;

: current-keywords ( -- keyword-map )
    current-rule-set keywords>> ;

: token, ( from to id -- )
    2over = [ 3drop ] [ >r line get subseq r> <token> , ] if ;

: prev-token, ( id -- )
    >r last-offset get position get r> token,
    position get last-offset set ;

: next-token, ( len id -- )
    >r position get 2dup + r> token,
    position get + dup 1- position set last-offset set ;

: push-context ( rules -- )
    context [ <line-context> ] change ;

: pop-context ( -- )
    context get parent>>
    f >>in-rule context set ;

: init-token-marker ( main prev-context line -- )
    line set
    [ ] [ f <line-context> ] ?if context set
    0 position set
    0 last-offset set
    0 whitespace-end set
    process-escape? on ;
