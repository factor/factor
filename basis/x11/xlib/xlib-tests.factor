USING: accessors alien.c-types kernel sequences tools.test words x11.io x11.xlib ;
IN: x11.xlib.tests

{ 12 } [ \ XCreateIC "declared-effect" word-prop in>> length ] unit-test
{ ulong } [ \ XCreateIC def>> 3 swap nth 6 swap nth ] unit-test
{ t } [ \ XCreateIC def>> 3 swap nth last pointer? ] unit-test
{ t } [ \ XCreateIC def>> 3 swap nth 6 swap nth heap-size ulong heap-size = ] unit-test
{ t } [ \ XCreateIC def>> last \ awaken-event-loop eq? ] unit-test
