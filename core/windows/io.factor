USING: kernel math sequences win32-api ;
IN: io-internals

! Allows use of the ui without native i/o.
! Overwritten when native i/o is loaded.
: io-multiplex ( ms -- ) 0 SleepEx drop ;

: directory-fixup ( seq -- seq )
    dup length zero? [
        dup peek CHAR: \\ = [ 1 head* ] when 
    ] unless "\\*" append ;
