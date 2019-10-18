! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: gadgets kernel models namespaces sequences arrays ;
IN: gadgets-text

: start-selection ( editor -- )
    dup editor-caret click-loc ;

: extend-selection ( editor -- )
    dup request-focus start-selection ;

: editor-cut ( editor clipboard -- )
    dupd gadget-copy remove-selection ;

: delete/backspace ( elt editor quot -- )
    over gadget-selection? [
        drop nip remove-selection
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
    >r dup editor-caret* swap control-model r> prev/next-elt
    r> editor-select ;

: select-all ( editor -- ) T{ doc-elt } select-elt ;

: start-of-document ( editor -- ) T{ doc-elt } editor-prev ;

: end-of-document ( editor -- ) T{ doc-elt } editor-next ;

: selected-word ( editor -- string )
    dup gadget-selection? [
        dup T{ one-word-elt } select-elt
    ] unless gadget-selection ;

: (position-caret) ( editor -- )
    dup extend-selection
    dup editor-mark click-loc ;

: position-caret ( editor -- )
    hand-click# get {
        [ ]
        [ dup (position-caret) ]
        [ dup T{ one-word-elt } select-elt ]
        [ dup T{ one-line-elt } select-elt ]
    } ?nth call drop ;

: insert-newline "\n" swap user-input ;

: delete-next-character T{ char-elt } editor-delete ;

: delete-previous-character T{ char-elt } editor-backspace ;

: delete-previous-word T{ word-elt } editor-delete ;

: delete-next-word T{ word-elt } editor-backspace ;

: delete-to-start-of-line T{ one-line-elt } editor-delete ;

: delete-to-end-of-line T{ one-line-elt } editor-backspace ;

editor "general" f {
    { T{ key-down f f "RET" } insert-newline }
    { T{ key-down f { S+ } "RET" } insert-newline }
    { T{ key-down f f "ENTER" } insert-newline }
    { T{ key-down f f "DELETE" } delete-next-character }
    { T{ key-down f { S+ } "DELETE" } delete-next-character }
    { T{ key-down f f "BACKSPACE" } delete-previous-character }
    { T{ key-down f { S+ } "BACKSPACE" } delete-previous-character }
    { T{ key-down f { C+ } "DELETE" } delete-previous-word }
    { T{ key-down f { C+ } "BACKSPACE" } delete-next-word }
    { T{ key-down f { A+ } "DELETE" } delete-to-start-of-line }
    { T{ key-down f { A+ } "BACKSPACE" } delete-to-end-of-line }
} define-command-map

: paste clipboard get paste-clipboard ;

: paste-selection selection get paste-clipboard ;

: cut clipboard get editor-cut ;

editor "clipboard" f {
    { T{ paste-action } paste }
    { T{ button-up f f 2 } paste-selection }
    { T{ copy-action } com-copy }
    { T{ button-up } com-copy-selection }
    { T{ cut-action } cut }
} define-command-map

: previous-character T{ char-elt } editor-prev ;

: next-character T{ char-elt } editor-next ;

: previous-line T{ line-elt } editor-prev ;

: next-line T{ line-elt } editor-next ;

: previous-word T{ word-elt } editor-prev ;

: next-word T{ word-elt } editor-next ;

: start-of-line T{ one-line-elt } editor-prev ;

: end-of-line T{ one-line-elt } editor-next ;

editor "caret-motion" f {
    { T{ button-down } position-caret }
    { T{ key-down f f "LEFT" } previous-character }
    { T{ key-down f f "RIGHT" } next-character }
    { T{ key-down f f "UP" } previous-line }
    { T{ key-down f f "DOWN" } next-line }
    { T{ key-down f { C+ } "LEFT" } previous-word }
    { T{ key-down f { C+ } "RIGHT" } next-word }
    { T{ key-down f f "HOME" } start-of-line }
    { T{ key-down f f "END" } end-of-line }
    { T{ key-down f { C+ } "HOME" } start-of-document }
    { T{ key-down f { C+ } "END" } end-of-document }
} define-command-map

: select-all T{ doc-elt } select-elt ;

: select-line T{ one-line-elt } select-elt ;

: select-word T{ one-word-elt } select-elt ;

: select-previous-character T{ char-elt } editor-select-prev ;

: select-next-character T{ char-elt } editor-select-next ;

: select-previous-line T{ line-elt } editor-select-prev ;

: select-next-line T{ line-elt } editor-select-next ;

: select-previous-word T{ word-elt } editor-select-prev ;

: select-next-word T{ word-elt } editor-select-next ;

: select-start-of-line T{ one-line-elt } editor-select-prev ;

: select-end-of-line T{ one-line-elt } editor-select-next ;

: select-start-of-document T{ doc-elt } editor-select-prev ;

: select-end-of-document T{ doc-elt } editor-select-next ;

editor "selection" f {
    { T{ button-down f { S+ } } extend-selection }
    { T{ drag } start-selection }
    { T{ gain-focus } focus-editor }
    { T{ lose-focus } unfocus-editor }
    { T{ delete-action } remove-selection }
    { T{ select-all-action } select-all }
    { T{ key-down f { C+ } "l" } select-line }
    { T{ key-down f { S+ } "LEFT" } select-previous-character }
    { T{ key-down f { S+ } "RIGHT" } select-next-character }
    { T{ key-down f { S+ } "UP" } select-previous-line }
    { T{ key-down f { S+ } "DOWN" } select-next-line }
    { T{ key-down f { S+ C+ } "LEFT" } select-previous-line }
    { T{ key-down f { S+ C+ } "RIGHT" } select-next-line }
    { T{ key-down f { S+ } "HOME" } select-start-of-line }
    { T{ key-down f { S+ } "END" } select-end-of-line }
    { T{ key-down f { S+ C+ } "HOME" } select-start-of-document }
    { T{ key-down f { S+ C+ } "END" } select-end-of-document }
} define-command-map
