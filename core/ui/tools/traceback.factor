! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel prettyprint gadgets gadgets-tracks namespaces
gadgets-listener models errors ;
IN: gadgets-traceback

: <callstack-display> ( model -- )
    [ [ continuation-call callstack. ] when* ]
    "Call stack" <labelled-pane> ;

: <datastack-display> ( model -- )
    [ [ continuation-data stack. ] when* ]
    "Data stack" <labelled-pane> ;

: <retainstack-display> ( model -- )
    [ [ continuation-retain stack. ] when* ]
    "Retain stack" <labelled-pane> ;

TUPLE: traceback-gadget ;

M: traceback-gadget pref-dim* drop { 300 400 } ;

C: traceback-gadget ( model -- gadget )
    dup rot { 0 1 } <track> delegate>control dup [
        [
            g control-model <datastack-display> 1/2 track,
            g control-model <retainstack-display> 1/2 track,
        ] { 1 0 } make-track 1/2 track,
        g control-model <callstack-display> 1/2 track,
    ] with-gadget ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-window ;

: com-traceback error-continuation get traceback-window ;

\ com-traceback H{ { +nullary+ t } } define-command

\ :help H{ { +nullary+ t } { +listener+ t } } define-command

\ :edit H{ { +nullary+ t } } define-command

debugger "toolbar" f {
    { T{ key-down f f "s" } com-traceback }
    { T{ key-down f f "h" } :help }
    { T{ key-down f f "e" } :edit }
} define-command-map
