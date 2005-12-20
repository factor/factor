IN: io
USING: kernel ;

! Think '/dev/null'.
M: f stream-close drop ;
M: f set-timeout drop ;

M: f stream-readln drop f ;
M: f stream-read1 drop f ;
M: f stream-read 2drop f ;

M: f stream-write1 2drop ;
M: f stream-write 2drop ;
M: f stream-terpri drop ;
M: f stream-terpri* drop ;
M: f stream-flush drop ;

M: f stream-format 3drop ;
M: f stream-bl drop ;
M: f with-nested-stream rot drop with-stream* ;
