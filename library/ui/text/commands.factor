! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls kernel models namespaces
sequences ;

: editor-mouse-down ( editor -- )
    dup request-focus
    dup
    dup editor-caret click-loc
    dup editor-mark click-loc ;

: editor-mouse-drag ( editor -- )
    dup editor-caret click-loc ;

: editor-copy ( editor clipboard -- )
    over editor-selection? [
        >r editor-selection r> set-clipboard-contents
    ] [
        2drop
    ] if ;

: editor-cut ( editor clipboard -- )
    dupd editor-copy remove-editor-selection ;

: delete/backspace ( elt editor quot -- | quot: caret editor -- from to )
    over editor-selection? [
        drop nip remove-editor-selection
    ] [
        over >r >r dup editor-caret* swap control-model
        r> call r> control-model remove-doc-range
    ] if ; inline

: editor-delete ( editor elt -- )
    swap [ over >r rot next-elt r> swap ] delete/backspace ;

: editor-backspace ( editor elt -- )
    swap [ over >r rot prev-elt r> ] delete/backspace ;

: editor-select-prev ( editor elt -- )
    swap [ rot prev-elt ] change-caret ;

: editor-prev ( editor elt -- )
    dupd editor-select-prev mark>caret ;

: editor-select-next ( editor elt -- )
    swap [ rot next-elt ] change-caret ;

: editor-next ( editor elt -- )
    dupd editor-select-next mark>caret ;

: editor-select ( from to editor -- )
    tuck editor-caret set-model editor-mark set-model ;

: select-elt ( editor elt -- )
    over >r
    >r dup editor-caret* swap control-model r>
    3dup next-elt >r prev-elt r>
    r> editor-select ;

editor H{
    { T{ button-down } [ editor-mouse-down ] }
    { T{ drag } [ editor-mouse-drag ] }
    { T{ gain-focus } [ focus-editor ] }
    { T{ lose-focus } [ unfocus-editor ] }
    { T{ paste-action } [ clipboard get paste-clipboard ] }
    { T{ button-up f 2 } [ selection get paste-clipboard ] }
    { T{ copy-action } [ clipboard get editor-copy ] }
    { T{ button-up } [ selection get editor-copy ] }
    { T{ cut-action } [ clipboard get editor-cut ] }
    { T{ delete-action } [ remove-editor-selection ] }
    { T{ select-all-action } [ T{ doc-elt } select-elt ] }
    { T{ key-down f { C+ } "l" } [ T{ one-line-elt } select-elt ] }
    { T{ key-down f { C+ } "w" } [ T{ word-elt } select-elt ] }
    { T{ key-down f f "LEFT" } [ T{ char-elt } editor-prev ] }
    { T{ key-down f f "RIGHT" } [ T{ char-elt } editor-next ] }
    { T{ key-down f f "UP" } [ T{ line-elt } editor-prev ] }
    { T{ key-down f f "DOWN" } [ T{ line-elt } editor-next ] }
    { T{ key-down f { S+ } "LEFT" } [ T{ char-elt } editor-select-prev ] }
    { T{ key-down f { S+ } "RIGHT" } [ T{ char-elt } editor-select-next ] }
    { T{ key-down f { S+ } "UP" } [ T{ line-elt } editor-select-prev ] }
    { T{ key-down f { S+ } "DOWN" } [ T{ line-elt } editor-select-next ] }
    { T{ key-down f { C+ } "LEFT" } [ T{ word-elt } editor-prev ] }
    { T{ key-down f { C+ } "RIGHT" } [ T{ word-elt } editor-next ] }
    { T{ key-down f { S+ C+ } "LEFT" } [ T{ word-elt } editor-select-prev ] }
    { T{ key-down f { S+ C+ } "RIGHT" } [ T{ word-elt } editor-select-next ] }
    { T{ key-down f f "HOME" } [ T{ one-line-elt } editor-prev ] }
    { T{ key-down f f "END" } [ T{ one-line-elt } editor-next ] }
    { T{ key-down f { S+ } "HOME" } [ T{ one-line-elt } editor-select-prev ] }
    { T{ key-down f { S+ } "END" } [ T{ one-line-elt } editor-select-next ] }
    { T{ key-down f { C+ } "HOME" } [ T{ doc-elt } editor-prev ] }
    { T{ key-down f { C+ } "END" } [ T{ doc-elt } editor-next ] }
    { T{ key-down f { C+ S+ } "HOME" } [ T{ doc-elt } editor-select-prev ] }
    { T{ key-down f { C+ S+ } "END" } [ T{ doc-elt } editor-select-next ] }
    { T{ key-down f f "DELETE" } [ T{ char-elt } editor-delete ] }
    { T{ key-down f f "BACKSPACE" } [ T{ char-elt } editor-backspace ] }
    { T{ key-down f { C+ } "DELETE" } [ T{ word-elt } editor-delete ] }
    { T{ key-down f { C+ } "BACKSPACE" } [ T{ word-elt } editor-backspace ] }
    { T{ key-down f { A+ } "DELETE" } [ T{ one-line-elt } editor-delete ] }
    { T{ key-down f { A+ } "BACKSPACE" } [ T{ one-line-elt } editor-backspace ] }
} set-gestures
