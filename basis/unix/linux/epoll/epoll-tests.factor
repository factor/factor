USING: alien.c-types arrays classes.parser classes.struct combinators kernel layouts
system tools.test unix.linux.epoll ;
IN: unix.linux.epoll.tests
<< SINGLETON: native-epoll-test-cpu >>
<<
"native-epoll-event-test" create-class-in
    "events" uint32_t
    "data" epoll-data [ f <struct-slot-spec> ] 2bi@ 2array
    native-epoll-test-cpu define-epoll-event-class
>>
! System z and the other natural-alignment ELF64 ABIs.
cell 8 = [
    { 16 8 } [
        native-epoll-event-test heap-size
        "data" native-epoll-event-test offset-of
    ] unit-test
] when
