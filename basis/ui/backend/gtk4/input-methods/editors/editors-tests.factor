USING: accessors documents kernel tools.test
ui.backend.gtk4.input-methods ui.backend.gtk4.input-methods.editors
ui.gadgets.editors ;

{ "aλz" 2 } [
    <editor> dup model>> "aλz" swap set-doc-string
    { 0 2 } over set-caret cursor-surrounding
] unit-test

{ "az" } [
    <editor> dup model>> "aλz" swap set-doc-string
    { 0 2 } over set-caret
    [ -1 1 rot delete-cursor-surrounding ] keep model>> doc-string
] unit-test
