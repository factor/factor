USING: xmode.marker.context xmode.rules
xmode.tokens namespaces kernel sequences assocs math ;
IN: xmode.marker.state

! Based on org.gjt.sp.jedit.syntax.TokenMarker

SYMBOL: rule-sets
SYMBOL: line
SYMBOL: last-offset
SYMBOL: position
SYMBOL: context

SYMBOL: whitespace-end
SYMBOL: seen-whitespace-end?

SYMBOL: escaped?
SYMBOL: process-escape?
SYMBOL: delegate-end-escaped?

: current-rule ( -- rule )
    context get line-context-in-rule ;

: current-rule-set ( -- rule )
    context get line-context-in-rule-set ;

: current-keywords ( -- keyword-map )
    current-rule-set rule-set-keywords ;

: token, ( from to id -- )
    pick pick = [ 3drop ] [ >r line get subseq r> <token> , ] if ;

: prev-token, ( id -- )
    >r last-offset get position get r> token,
    position get last-offset set ;

: next-token, ( len id -- )
    >r position get 2dup + r> token,
    position get + dup 1- position set last-offset set ;

: get-rule-set ( name -- rule-set )
    rule-sets get at ;

: main-rule-set ( -- rule-set )
    "MAIN" get-rule-set ;

: push-context ( rules -- )
    context [ <line-context> ] change ;

: pop-context ( -- )
    context get line-context-parent
    dup context set
    f swap set-line-context-in-rule ;

: terminal-rule-set ( -- rule-set )
    get-rule-set rule-set-default standard-rule-set
    push-context ;

: init-token-marker ( prev-context line rules -- )
    rule-sets set
    line set
    0 position set
    0 last-offset set
    0 whitespace-end set
    process-escape? on
    [ clone ] [ main-rule-set f <line-context> ] if*
    context set ;
