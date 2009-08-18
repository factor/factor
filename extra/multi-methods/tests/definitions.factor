USING: multi-methods tools.test math sequences namespaces system
kernel strings words compiler.units quotations ;
IN: multi-methods.tests

DEFER: fake
\ fake H{ } clone "multi-methods" set-word-prop
<< (( -- )) \ fake set-stack-effect >>

[ "fake-{ }" ] [ { } \ fake method-word-name ] unit-test

[ H{ { "multi-method-generic" fake } { "multi-method-specializer" { } } } ]
[ { } \ fake method-word-props ] unit-test

[ t ] [ { } \ fake <method> method-body? ] unit-test

[
    [ { } [ ] ] [ \ fake methods prepare-methods [ sort-methods ] dip ] unit-test

    [ t ] [ { } \ fake multi-dispatch-quot callable? ] unit-test

    [ t ] [ \ fake make-generic quotation? ] unit-test

    [ ] [ \ fake update-generic ] unit-test

    DEFER: testing

    [ ] [ \ testing (( -- )) define-generic ] unit-test

    [ t ] [ \ testing generic? ] unit-test
] with-compilation-unit
