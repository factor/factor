! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces math accessors alien locals
destructors system threads io.backend.unix.multiplexers
io.backend.unix.multiplexers.kqueue core-foundation
core-foundation.run-loop core-foundation.file-descriptors ;
FROM: alien.c-types => void void* ;
IN: io.backend.unix.multiplexers.run-loop

TUPLE: run-loop-mx kqueue-mx ;

: file-descriptor-callback ( -- callback )
    [
        2drop
        0 mx get-global kqueue-mx>> wait-for-events
        enable-all-callbacks
        reset-thread-timer
        yield
    ] CFFileDescriptorCallBack ;

: <run-loop-mx> ( -- mx )
    [
        <kqueue-mx> |dispose
        dup fd>> file-descriptor-callback add-fd-to-run-loop
        run-loop-mx boa
    ] with-destructors ;

M: run-loop-mx add-input-callback kqueue-mx>> add-input-callback ;
M: run-loop-mx add-output-callback kqueue-mx>> add-output-callback ;
M: run-loop-mx remove-input-callbacks kqueue-mx>> remove-input-callbacks ;
M: run-loop-mx remove-output-callbacks kqueue-mx>> remove-output-callbacks ;

M: run-loop-mx wait-for-events
    swap run-one-iteration [ 0 swap wait-for-events ] [ drop ] if ;
