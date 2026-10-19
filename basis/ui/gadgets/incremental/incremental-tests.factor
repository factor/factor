USING: accessors arrays concurrency.promises kernel locals math namespaces
sequences threads tools.test ui ui.gadgets ui.gadgets.incremental
ui.gadgets.private vectors ;
IN: ui.gadgets.incremental.tests

! Queue backpressure must not suspend an append between parenting the child
! and updating its location, the cursor and the preferred dimensions.
:: observe-append ( -- yielded? cursor dim )
    <incremental> :> container
    <promise> :> observed
    8000 f <array> >vector \ layout-queue [
        [ container [ cursor>> ] [ dim>> ] bi 2array observed fulfill ]
        "Observe incremental append" spawn drop
        <gadget> { 10 20 } >>dim container add-incremental
        observed promise-fulfilled?
        observed ?promise first2
    ] with-variable ;

ui-running? [
    { t { 10 20 } { 10 20 } } [ observe-append ] unit-test
] unless
