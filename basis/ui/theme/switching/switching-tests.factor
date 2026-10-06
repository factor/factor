USING: accessors colors continuations fonts kernel locals namespaces
sequences tools.test ui.theme ui.theme.switching ;
IN: ui.theme.switching.tests

! Plain demos also need themed fonts when the development tools are absent.
:: themed-fonts? ( -- ? )
    theme get-global :> previous-theme
    default-theme? get-global :> previous-default?
    [
        { light-theme dark-theme } [
            switch-theme sans-serif-font
            [ foreground>> text-color color= ]
            [ background>> content-background color= ] bi and
        ] all?
    ] [
        previous-theme switch-theme
        previous-default? default-theme? set-global
    ] finally ;

{ t } [ themed-fonts? ] unit-test
