USING: assocs core-text.fonts io.styles kernel ui.commands ui.gestures
ui.tools.listener.completion vocabs.refresh ;

IN: ui.tools.listener
interactor "interactor" f {
    { T{ key-down f f "RET" } evaluate-input }
    { T{ key-down f { C+ } "d" } delete-next-character/eof }
} define-command-map

interactor "completion" f {
    { T{ key-down f f "TAB" } code-completion-popup }
    { T{ key-down f { C+ } "p" } recall-previous }
    { T{ key-down f { C+ } "n" } recall-next }
    { T{ key-down f { M+ } "UP" } recall-previous }
    { T{ key-down f { M+ } "DOWN" } recall-next }
    { T{ key-down f { C+ } "r" } history-completion-popup }
    { T{ key-down f { C+ } "s" } history-completion-popup }
} define-command-map

listener-gadget "multi-touch" f {
    { left-action recall-previous }
    { right-action recall-next }
    { up-action refresh-all }
} define-command-map

! <PRIVATE

! FROM: core-text.fonts => font-name ; 
! :: make-font-style ( family size -- assoc )
!     H{ } clone
!         family font-name pick set-at
!         size font-size pick set-at ;

! PRIVATE>
