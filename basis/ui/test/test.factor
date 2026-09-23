USING: continuations fry kernel locals namespaces opengl ;
IN: ui.test

! Layout tests must not inherit the listener window's display scale.
:: with-ui-test-scale ( scale quot -- )
    gl-scale-factor get-global :> previous
    [ scale gl-scale-factor set-global quot call ]
    [ previous gl-scale-factor set-global ] finally ; inline

! The test reporter may redraw a window and change the global scale before
! executing an assertion. Set the scale inside the test quotation itself.
: unscaled-ui-test ( quot -- quot' )
    '[ f _ with-ui-test-scale ] ;
