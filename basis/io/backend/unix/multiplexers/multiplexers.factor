! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs destructors kernel sequences threads ;
IN: io.backend.unix.multiplexers

TUPLE: mx < disposable fd reads writes ;

: new-mx ( class -- obj )
    new-disposable
        H{ } clone >>reads
        H{ } clone >>writes ; inline

GENERIC: add-input-callback ( thread fd mx -- )

M: mx add-input-callback reads>> push-at ;

GENERIC: add-output-callback ( thread fd mx -- )

M: mx add-output-callback writes>> push-at ;

GENERIC: remove-input-callbacks ( fd mx -- callbacks )

M: mx remove-input-callbacks reads>> delete-at* drop ;

GENERIC: remove-output-callbacks ( fd mx -- callbacks )

M: mx remove-output-callbacks writes>> delete-at* drop ;

GENERIC: wait-for-events ( nanos mx -- )

: input-available ( fd mx -- )
    reads>> delete-at* drop [ resume ] each ;

: output-available ( fd mx -- )
    writes>> delete-at* drop [ resume ] each ;
