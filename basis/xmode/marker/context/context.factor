USING: accessors kernel xmode.rules ;
IN: xmode.marker.context

! Based on org.gjt.sp.jedit.syntax.TokenMarker.LineContext
TUPLE: line-context
parent
in-rule
in-rule-set
end
;

: <line-context> ( ruleset parent -- line-context )
    over rule-set? [ "not a rule-set" throw ] unless
    line-context new
        swap >>parent
        swap >>in-rule-set ;

M: line-context clone
    call-next-method [ clone ] change-parent ;
