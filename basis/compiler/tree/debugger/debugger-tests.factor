USING: accessors arrays assocs compiler.tree compiler.tree.builder
compiler.tree.checker compiler.tree.debugger compiler.tree.debugger.private
continuations effects io kernel math math.order quotations sequences
sequences.product sorting tools.test ;
QUALIFIED: shuffle
IN: compiler.tree.debugger.tests

[ [ <=> ] sort-with ] optimized.
[ <reversed> write-lines ] optimizer-report.

{ [ ] } [ [ rot -rot swap swap ] build-tree nodes>quot ] unit-test
{ [ dup ] } [ [ dup swap ] build-tree nodes>quot ] unit-test
{ [ ] } [ ( a b c d e -- a b c d e ) pretty-shuffle ] unit-test

! SSA names may change across an identity copy omitted from the view.
{ { 1 } { 1 1 } } [
    { 1 } { 2 3 } { { 2 1 } { 3 1 } } <#data-shuffle>
    { 4 5 } { 6 7 } { { 6 5 } { 7 4 } } <#data-shuffle>
    compose-data-shuffles dup check-node*
    shuffle-effect [ in>> ] [ out>> ] bi
] unit-test

: executable-shuffle-view ( quot -- quot' )
    build-tree nodes>quot [
        dup shuffle-node?
        [ effect>> '[ _ shuffle:shuffle-effect ] ] [ 1quotation ] if
    ] map concat >quotation ;

:: same-shuffle-result? ( quot -- ? )
    16 <iota> >array quot with-datastack
    16 <iota> >array quot executable-shuffle-view with-datastack = ;

! Compare with execution, including duplicates, drops and deeper inputs.
{ t } [
    { dup drop swap over nip rot -rot 2dup }
    3 swap <repetition> all-products
    [ >quotation same-shuffle-result? ] all?
] unit-test

! A later shuffle can reach below the inputs of the first shuffle.
{ { 4 1 } { 1 4 1 } } [
    { 1 } { 2 3 } { { 2 1 } { 3 1 } } <#data-shuffle>
    { 4 5 6 } { 7 8 9 } { { 7 5 } { 8 4 } { 9 6 } } <#data-shuffle>
    compose-data-shuffles shuffle-effect [ in>> ] [ out>> ] bi
] unit-test

! Keep calls, literals and retain-stack transfers in order.
: opaque-call ( x -- x ) ;
{ [ swap opaque-call swap ] } [
    [ swap opaque-call swap ] build-tree nodes>quot
] unit-test
{ [ swap 1 swap ] } [ [ swap 1 swap ] build-tree nodes>quot ] unit-test
{ [ >R swap R> swap ] } [
    [ [ swap ] dip swap ] build-tree nodes>quot
] unit-test

! Composition is a view operation; the input IR remains intact.
{ { 1 } { 1 1 } { 4 5 } { 5 4 } } [
    { 1 } { 2 3 } { { 2 1 } { 3 1 } } <#data-shuffle>
    { 4 5 } { 6 7 } { { 6 5 } { 7 4 } } <#data-shuffle>
    [ compose-data-shuffles drop ] 2keep
    [ shuffle-effect [ in>> ] [ out>> ] bi ] bi@
] unit-test
