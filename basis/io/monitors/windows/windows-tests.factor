USING: accessors destructors io.monitors.windows kernel tools.test
windows.errors ;
IN: io.monitors.windows.tests

: stopped-monitor ( -- monitor )
    win32-monitor new win32-monitor-port new t >>disposed >>port ;

{ t } [
    T{ windows-error { n 995 } } stopped-monitor monitor-stopped-error?
] unit-test

! Cancellation is benign only when the monitor's port was disposed.
{ f } [
    T{ windows-error { n 995 } }
    win32-monitor new win32-monitor-port new >>port
    monitor-stopped-error?
] unit-test

{ f } [
    T{ windows-error { n 5 } } stopped-monitor monitor-stopped-error?
] unit-test

{ f } [ "unexpected failure" stopped-monitor monitor-stopped-error? ] unit-test
{ t } [ T{ already-disposed } stopped-monitor monitor-stopped-error? ] unit-test
