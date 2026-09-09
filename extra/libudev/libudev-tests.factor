! Check the deprecated callback's complete signature without opening libudev.
USING: effects libudev tools.test words ;
IN: libudev.tests

{ ( udev priority file line fn format args -- ) } [
    \ udev_set_log_fn_callback "callback-effect" word-prop
] unit-test
