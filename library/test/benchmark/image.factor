IN: temporary
USING: generic image kernel math namespaces parser test ;

[
    "/library/bootstrap/boot-stage1.factor" run-resource
] with-image drop

[ fixnum ] [ 4 class ] unit-test
