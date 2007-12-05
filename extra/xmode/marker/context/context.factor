USING: kernel ;
IN: xmode.marker.context

! Based on org.gjt.sp.jedit.syntax.TokenMarker.LineContext
TUPLE: line-context
parent
in-rule
in-rule-set
end
;

: <line-context> ( ruleset parent -- line-context )
    { set-line-context-in-rule-set set-line-context-parent }
    line-context construct ;

M: line-context clone
    (clone)
    dup line-context-parent clone
    over set-line-context-parent ;
