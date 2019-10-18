USING: gadgets-text test kernel io definitions namespaces
gadgets ;

[ t ] [
    <editor> "editor" set
    "editor" get graft*
    "editor" get <plain-writer> [ \ = see ] with-stream
    "editor" get editor-string [ \ = see ] string-out =
    "editor" get ungraft*
] unit-test

[ "foo bar" ] [
    <editor> "editor" set
    "editor" get graft*
    "foo bar" "editor" get set-editor-string
    "editor" get T{ one-line-elt } select-elt
    "editor" get gadget-selection
    "editor" get ungraft*
] unit-test

[ "baz quux" ] [
    <editor> "editor" set
    "editor" get graft*
    "foo bar\nbaz quux" "editor" get set-editor-string
    "editor" get T{ one-line-elt } select-elt
    "editor" get gadget-selection
    "editor" get ungraft*
] unit-test
