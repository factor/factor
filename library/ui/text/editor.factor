! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays errors freetype gadgets gadgets-borders
gadgets-buttons gadgets-controls gadgets-frames gadgets-labels
gadgets-scrolling gadgets-theme io kernel math models namespaces
opengl sequences strings styles ;

TUPLE: editor
font color caret-color selection-color
caret mark
focused? ;

: init-editor-models ( editor -- )
    dup control-self over editor-caret add-connection
    dup control-self swap editor-mark add-connection ;

C: editor ( document -- editor )
    dup <document> delegate>control
    dup dup set-control-self
    { 0 0 } <model> over set-editor-caret
    { 0 0 } <model> over set-editor-mark
    dup init-editor-models
    dup editor-theme ;

: activate-editor-model ( editor model -- )
    dup activate-model swap control-model add-loc ;

: deactivate-editor-model ( editor model -- )
    dup deactivate-model swap control-model remove-loc ;

M: editor graft* ( editor -- )
    dup dup editor-caret activate-editor-model
    dup dup editor-mark activate-editor-model
    dup control-self swap control-model add-connection ;

M: editor ungraft* ( editor -- )
    dup dup editor-caret deactivate-editor-model
    dup dup editor-mark deactivate-editor-model
    dup control-self swap control-model remove-connection ;

M: editor model-changed ( editor -- )
    #! Document changed
    control-self relayout ;

: editor-caret* editor-caret model-value ;

: editor-mark* editor-mark model-value ;

: change-caret ( editor quot -- )
    over >r >r dup editor-caret* swap control-model r> call r>
    [ control-model validate-loc ] keep
    editor-caret set-model ; inline

: mark>caret ( editor -- )
    dup editor-caret* swap editor-mark set-model ;

: change-caret&mark ( editor quot -- )
    over >r change-caret r> mark>caret ; inline

: editor-lines ( editor -- seq )
    control-model model-value ;

: editor-line ( n editor -- str ) editor-lines nth ;

: editor-font* ( editor -- font ) editor-font lookup-font ;

: line-height ( editor -- n )
    editor-font* font-height ;

: run-char-widths ( str editor -- wlist )
    #! List of x co-ordinates of each character.
    editor-font* swap >array [ char-width ] map-with
    dup 0 [ + ] accumulate swap 2 v/n v+ ;

: x>offset ( x line# editor -- col# )
    [ editor-line ] keep
    over >r run-char-widths [ <= ] find-with drop dup -1 =
    [ drop r> length ] [ r> drop ] if ;

: y>line ( y editor -- line# )
    [ line-height / >fixnum ] keep control-model validate-line ;

: point>loc ( point editor -- loc )
    over second over y>line [
        >r >r first r> r> swap x>offset
    ] keep swap 2array ;

: click-loc ( editor model -- )
    >r [ hand-rel ] keep point>loc r> set-model ;

: focus-editor ( editor -- )
    t over set-editor-focused? relayout-1 ;

: unfocus-editor ( editor -- )
    f over set-editor-focused? relayout-1 ;

: (offset>x) ( font col# str -- x )
    head-slice string-width ;

: offset>x ( col# line# editor -- x )
    [ editor-line ] keep editor-font* -rot (offset>x) ;

: loc>x ( loc editor -- x ) >r first2 swap r> offset>x ;

: (draw-caret) ( loc editor -- )
    dup editor-caret-color gl-color
    [ loc>x ] keep line-height dupd 2array >r 0 2array r>
    gl-line ;

: draw-caret ( n editor -- )
    {
        { [ dup editor-focused? not ] [ ] }
        { [ 2dup editor-caret* first = not ] [ ] }
        { [ t ] [ dup editor-caret* over (draw-caret) ] }
    } cond 2drop ;

: translate-lines ( n -- )
    editor get line-height * 0.0 swap 0.0 glTranslated ;

: draw-line ( str n -- )
    editor get draw-caret
    editor get editor-color gl-color
    >r editor get editor-font r> draw-string ;

: with-editor ( editor quot -- )
    [
        swap dup control-model document set editor set call
    ] with-scope ; inline

: draw-lines ( editor -- )
    GL_MODELVIEW [
        editor get editor-lines dup length
        [ draw-line 1 translate-lines ] 2each
    ] do-matrix ;

: selection-start/end ( editor -- start end )
    dup editor-mark* swap editor-caret*
    2dup <=> 0 > [ swap ] when ;

: (draw-selection) ( x1 x2 -- )
    2dup = [ 2 + ] when
    0.0 swap editor get line-height glRectd ;

: draw-selected-line ( start end n -- )
    [ start/end-on-line ] keep tuck
    >r >r editor get offset>x r> r>
    editor get offset>x
    (draw-selection) ;

: translate>selection-start ( start -- )
    first translate-lines ;

: draw-selection ( -- )
    GL_MODELVIEW [
        editor get
        dup editor-selection-color gl-color
        selection-start/end
        over translate>selection-start
        2dup [
            >r 2dup r> draw-selected-line 1 translate-lines
        ] each-line 2drop
    ] do-matrix ;

M: editor draw-gadget* ( gadget -- )
    [ draw-selection draw-lines ] with-editor ;

: line>y ( lines# editor -- y )
    line-height * ;

: editor-height ( editor -- n )
    [ editor-lines length ] keep line>y ;

: editor-width ( editor -- n )
    0 swap dup editor-font* swap editor-lines
    [ string-width max ] each-with ;

M: editor pref-dim* ( editor -- dim )
    dup editor-width swap editor-height 2array ;

: editor-selection? ( editor -- ? )
    selection-start/end = not ;

: editor-selection ( editor -- str )
    [ selection-start/end ] keep control-model doc-range ;

: remove-editor-selection ( editor -- )
    [ selection-start/end ] keep control-model
    remove-doc-range ;

M: editor user-input* ( str editor -- ? )
    [ selection-start/end ] keep control-model set-doc-range t ;

: editor-text ( editor -- str )
    control-model doc-text ;

: set-editor-text ( str editor -- )
    control-model set-doc-text ;
