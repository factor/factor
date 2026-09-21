USING: kernel tools.test ui.backend.gtk4.smoke-test ui.gadgets.worlds ;
IN: ui.backend.gtk4.smoke-test.tests

! open-window* returns before the queued graft creates a native handle.
{ f } [
    T{ world { dim { 640 360 } } } window-ready?
] unit-test

! Even an active world must not query GTK without a handle.
{ f } [
    T{ world { dim { 640 360 } } { active? t } } window-ready?
] unit-test

! Timeout diagnostics must also tolerate an uncreated/destroyed window.
{ { 0 0 } } [ T{ world } native-dim ] unit-test
