USING: accessors assocs destructors io.backend.unix
io.backend.unix.multiplexers io.backend.unix.multiplexers.epoll
io.sockets kernel locals sequences threads tools.test ;
IN: io.backend.unix.multiplexers.epoll.tests

! The same fd can have multiple readers and a writer. Cancelling readers
! must keep the write registration in the kernel, and vice versa.
{ 2 t 1 } [
    [
      [let
        <epoll-mx> &dispose :> mx
        "127.0.0.1" 0 <inet4> <datagram> &dispose handle>> handle-fd :> fd
        self fd mx add-input-callback
        self fd mx add-input-callback
        self fd mx add-output-callback
        fd mx remove-input-callbacks length
        fd mx writes>> key?
        mx 0 wait-event
        fd mx remove-output-callbacks drop
      ]
    ] with-destructors
] unit-test

{ 1 t 1 } [
    [
      [let
        <epoll-mx> &dispose :> mx
        "127.0.0.1" 0 <inet4> <datagram> &dispose handle>> handle-fd :> fd
        self fd mx add-output-callback
        self fd mx add-input-callback
        fd mx remove-output-callbacks length
        fd mx reads>> key?
        fd mx remove-input-callbacks length
      ]
    ] with-destructors
] unit-test
