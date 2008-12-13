! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces math accessors threads alien locals
destructors combinators io.unix.multiplexers
io.unix.multiplexers.kqueue core-foundation
core-foundation.run-loop core-foundation.file-descriptors ;
IN: io.unix.multiplexers.run-loop

TUPLE: run-loop-mx kqueue-mx fd source ;

: kqueue-callback ( -- callback )
    "void" { "CFFileDescriptorRef" "CFOptionFlags" "void*" }
    "cdecl" [
        3drop
        0 mx get kqueue-mx>> wait-for-events
        mx get fd>> enable-all-callbacks
        yield
    ]
    alien-callback ;

SYMBOL: kqueue-run-loop-source

: create-kqueue-source ( fd -- source )
    f swap 0 CFFileDescriptorCreateRunLoopSource ;

: add-kqueue-to-run-loop ( mx -- )
    CFRunLoopGetMain swap source>> CFRunLoopDefaultMode CFRunLoopAddSource ;

: remove-kqueue-from-run-loop ( source -- )
    CFRunLoopGetMain swap source>> CFRunLoopDefaultMode CFRunLoopRemoveSource ;

: <run-loop-mx> ( -- mx )
    [
        <kqueue-mx> |dispose
        dup fd>> kqueue-callback <CFFileDescriptor> |dispose
        dup create-kqueue-source run-loop-mx boa
        dup add-kqueue-to-run-loop
    ] with-destructors ;

M: run-loop-mx dispose
    [
        {
            [ fd>> &CFRelease drop ]
            [ source>> &CFRelease drop ]
            [ remove-kqueue-from-run-loop ]
            [ kqueue-mx>> &dispose drop ]
        } cleave
    ] with-destructors ;

M: run-loop-mx add-input-callback kqueue-mx>> add-input-callback ;
M: run-loop-mx add-output-callback kqueue-mx>> add-output-callback ;
M: run-loop-mx remove-input-callbacks kqueue-mx>> remove-input-callbacks ;
M: run-loop-mx remove-output-callbacks kqueue-mx>> remove-output-callbacks ;

M:: run-loop-mx wait-for-events ( us mx -- )
    mx fd>> enable-all-callbacks
    CFRunLoopDefaultMode us [ 1000000 /f ] [ 60 ] if* t CFRunLoopRunInMode
    kCFRunLoopRunHandledSource = [ 0 mx wait-for-events ] when ;
