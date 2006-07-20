! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets kernel models namespaces sequences ;

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

: remove-at-caret ( editor quot -- | quot: caret editor -- from to )
    over >r >r dup editor-caret* swap editor-document
    r> call r> editor-document remove-doc-range ; inline

: editor-delete ( editor -- )
    dup editor-selection? [
        remove-editor-selection
    ] [
        [ dupd T{ char-elt } next-elt ] remove-at-caret
    ] if ;

: editor-backspace ( editor -- )
    dup editor-selection? [
        remove-editor-selection
    ] [
        [ dupd T{ char-elt } prev-elt swap ] remove-at-caret
    ] if ;

: editor-select-prev ( editor elt -- )
    swap [ rot prev-elt ] change-caret ;

: editor-prev ( editor elt -- )
    dupd editor-select-prev mark>caret ;

: editor-select-next ( editor elt -- )
    swap [ rot next-elt ] change-caret ;

: editor-next ( editor elt -- )
    dupd editor-select-next mark>caret ;

: editor-select-home ( editor -- )
    [ drop 0 swap =col ] change-caret ;

: editor-home ( editor -- )
    dup editor-select-home mark>caret ;

: editor-select-doc-home ( editor -- )
    { 0 0 } swap editor-caret set-model ;

: editor-doc-home ( editor -- )
    editor-select-doc-home mark>caret ;

: editor-select-end ( editor -- )
    [ >r first r> line-end ] change-caret ;

: editor-end ( editor -- )
    dup editor-select-end mark>caret ;

: editor-select-doc-end ( editor -- )
    dup editor-document doc-end swap editor-caret set-model ;

: editor-doc-end ( editor -- )
    editor-select-doc-end mark>caret ;

: editor-select-all ( editor -- )
    { 0 0 } over editor-caret set-model
    dup editor-document doc-end swap editor-mark set-model ;

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
    { T{ select-all-action } [ editor-select-all ] }
    { T{ key-down f f "LEFT" } [ T{ char-elt } editor-prev ] }
    { T{ key-down f f "RIGHT" } [ T{ char-elt } editor-next ] }
    { T{ key-down f f "UP" } [ T{ line-elt } editor-prev ] }
    { T{ key-down f f "DOWN" } [ T{ line-elt } editor-next ] }
    { T{ key-down f { S+ } "LEFT" } [ T{ char-elt } editor-select-prev ] }
    { T{ key-down f { S+ } "RIGHT" } [ T{ char-elt } editor-select-next ] }
    { T{ key-down f { S+ } "UP" } [ T{ line-elt } editor-select-prev ] }
    { T{ key-down f { S+ } "DOWN" } [ T{ line-elt } editor-select-next ] }
    { T{ key-down f f "HOME" } [ editor-home ] }
    { T{ key-down f f "END" } [ editor-end ] }
    { T{ key-down f { S+ } "HOME" } [ editor-select-home ] }
    { T{ key-down f { S+ } "END" } [ editor-select-end ] }
    { T{ key-down f { S+ } "HOME" } [ editor-select-home ] }
    { T{ key-down f { S+ } "END" } [ editor-select-end ] }
    { T{ key-down f { C+ } "HOME" } [ editor-doc-home ] }
    { T{ key-down f { C+ } "END" } [ editor-doc-end ] }
    { T{ key-down f { C+ S+ } "HOME" } [ editor-select-doc-home ] }
    { T{ key-down f { C+ S+ } "END" } [ editor-select-doc-end ] }
    { T{ key-down f f "DELETE" } [ editor-delete ] }
    { T{ key-down f f "BACKSPACE" } [ editor-backspace ] }
} set-gestures
