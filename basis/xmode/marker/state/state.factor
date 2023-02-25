! Copyright (C) 2007, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel make math namespaces sequences
xmode.marker.context xmode.tokens ;
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
    2over = [ 3drop ] [ [ line get subseq ] dip <token> , ] if ;

: prev-token, ( id -- )
    [ last-offset get position get ] dip token,
    position get last-offset set ;

: next-token, ( len id -- )
    [ position get 2dup + ] dip token,
    position get + dup 1 - position set last-offset set ;

: push-context ( rules -- )
    context [ <line-context> ] change ;

: pop-context ( -- )
    context get parent>>
    f >>in-rule context set ;

: init-token-marker ( main prev-context line -- )
    line set or* [ f <line-context> ] unless context set
    0 position set
    0 last-offset set
    0 whitespace-end set
    process-escape? on ;
