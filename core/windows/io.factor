USING: kernel win32-api ;
IN: io-internals

! Allows use of the ui without native i/o.
! Overwritten when native i/o is loaded.
: io-multiplex ( ms -- ) 0 SleepEx drop ;

