USING: accessors effects kernel libudev tools.test words ;
IN: libudev.tests

! Deterministic missing capability; no udev object or device is touched.
{ f } [ "factor_deliberately_missing_udev_symbol" udev-function-available? ] unit-test
[ "factor_deliberately_missing_udev_symbol" require-udev-function ]
[ unavailable-udev-function? ] must-fail-with

! Check the deprecated callback's complete signature without opening libudev.
{ ( udev priority file line fn format args -- ) } [
    \ udev_set_log_fn_callback "callback-effect" word-prop
] unit-test
