! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls kernel models namespaces
sequences ;

: editor-extend-selection ( editor -- )
    dup request-focus
    dup editor-caret click-loc ;

: editor-mouse-down ( editor -- )
    dup editor-extend-selection
    dup editor-mark click-loc ;

: editor-mouse-drag ( editor -- )
    dup editor-caret click-loc ;

: editor-copy ( editor clipboard -- )
    over gadget-selection? [
        >r [ gadget-selection ] keep r> copy-clipboard
    ] [
        2drop
    ] if ;

: editor-cut ( editor clipboard -- )
    dupd editor-copy remove-editor-selection ;

: delete/backspace ( elt editor quot -- )
    over gadget-selection? [
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
    tuck editor-caret set-model* editor-mark set-model* ;

: select-elt ( editor elt -- )
    over >r
    >r dup editor-caret* swap control-model r>
    3dup next-elt >r prev-elt r>
    r> editor-select ;

: select-all ( editor -- ) T{ doc-elt } select-elt ;

: editor-doc-start ( editor -- ) T{ doc-elt } editor-prev ;

: editor-doc-end ( editor -- ) T{ doc-elt } editor-next ;

editor {
    {
        "Editing"
        { "Insert newline" T{ key-down f f "RETURN" } [ "\n" swap user-input ] }
        { "Insert newline" T{ key-down f { S+ } "RETURN" } [ "\n" swap user-input ] }
        { "Insert newline" T{ key-down f f "ENTER" } [ "\n" swap user-input ] }
        { "Delete next character" T{ key-down f f "DELETE" } [ T{ char-elt } editor-delete ] }
        { "Delete previous character" T{ key-down f f "BACKSPACE" } [ T{ char-elt } editor-backspace ] }
        { "Delete previous word" T{ key-down f { C+ } "DELETE" } [ T{ word-elt } editor-delete ] }
        { "Delete next word" T{ key-down f { C+ } "BACKSPACE" } [ T{ word-elt } editor-backspace ] }
        { "Delete to start of line" T{ key-down f { A+ } "DELETE" } [ T{ one-line-elt } editor-delete ] }
        { "Delete to end of line" T{ key-down f { A+ } "BACKSPACE" } [ T{ one-line-elt } editor-backspace ] }
    }
    
    {
        "Clipboard"
        { "Paste" T{ paste-action } [ clipboard get paste-clipboard ] }
        { "Paste selection" T{ button-up f f 2 } [ selection get paste-clipboard ] }
        { "Copy" T{ copy-action } [ clipboard get editor-copy ] }
        { "Copy selection" T{ button-up } [ selection get editor-copy ] }
        { "Cut" T{ cut-action } [ clipboard get editor-cut ] }
    }

    {
        "Moving caret"
        { "Position caret" T{ button-down } [ editor-mouse-down ] }
        { "Previous character" T{ key-down f f "LEFT" } [ T{ char-elt } editor-prev ] }
        { "Next character" T{ key-down f f "RIGHT" } [ T{ char-elt } editor-next ] }
        { "Previous line" T{ key-down f f "UP" } [ T{ line-elt } editor-prev ] }
        { "Next line" T{ key-down f f "DOWN" } [ T{ line-elt } editor-next ] }
        { "Previous word" T{ key-down f { C+ } "LEFT" } [ T{ word-elt } editor-prev ] }
        { "Next word" T{ key-down f { C+ } "RIGHT" } [ T{ word-elt } editor-next ] }
        { "Start of line" T{ key-down f f "HOME" } [ T{ one-line-elt } editor-prev ] }
        { "End of line" T{ key-down f f "END" } [ T{ one-line-elt } editor-next ] }
        { "Start of document" T{ key-down f { C+ } "HOME" } [ editor-doc-start ] }
        { "End of document" T{ key-down f { C+ } "END" } [ editor-doc-end ] }
    }
    
    {
        "Selecting text"
        { "Extend selection" T{ button-down f { S+ } } [ editor-extend-selection ] }
        { "Start selection" T{ drag } [ editor-mouse-drag ] }
        { "Focus editor" T{ gain-focus } [ focus-editor ] }
        { "Unfocus editor" T{ lose-focus } [ unfocus-editor ] }
        { "Clear" T{ delete-action } [ remove-editor-selection ] }
        { "Select all" T{ select-all-action } [ T{ doc-elt } select-elt ] }
        { "Select line" T{ key-down f { C+ } "l" } [ T{ one-line-elt } select-elt ] }
        { "Select word" T{ key-down f { C+ } "w" } [ T{ word-elt } select-elt ] }
        { "Select previous character" T{ key-down f { S+ } "LEFT" } [ T{ char-elt } editor-select-prev ] }
        { "Select next character" T{ key-down f { S+ } "RIGHT" } [ T{ char-elt } editor-select-next ] }
        { "Select previous line" T{ key-down f { S+ } "UP" } [ T{ line-elt } editor-select-prev ] }
        { "Select next line" T{ key-down f { S+ } "DOWN" } [ T{ line-elt } editor-select-next ] }
        { "Select previous line" T{ key-down f { S+ C+ } "LEFT" } [ T{ word-elt } editor-select-prev ] }
        { "Select next line" T{ key-down f { S+ C+ } "RIGHT" } [ T{ word-elt } editor-select-next ] }
        { "Select to start of line" T{ key-down f { S+ } "HOME" } [ T{ one-line-elt } editor-select-prev ] }
        { "Select to end of line" T{ key-down f { S+ } "END" } [ T{ one-line-elt } editor-select-next ] }
        { "Select start of document" T{ key-down f { C+ S+ } "HOME" } [ T{ doc-elt } editor-select-prev ] }
        { "Select end of document" T{ key-down f { C+ S+ } "END" } [ T{ doc-elt } editor-select-next ] }
    }
} define-commands
