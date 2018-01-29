USING: assocs kernel threads tools.test ui ;
IN: ui.tests

{ t } [
    ! with-ui shouldn't leave any thread hanging around.
    threads assoc-size
    [ ] with-ui
    threads assoc-size =
] unit-test
