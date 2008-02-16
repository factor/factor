USING: io io.encodings strings kernel ;
IN: io.encodings.latin1

TUPLE: latin1 stream ;

M: latin1 init-decoding tuck set-latin1-stream ;
M: latin1 init-encoding drop ;

M: latin1 stream-read1
    latin1-stream stream-read1 ;

M: latin1 stream-read
    latin1-stream stream-read >string ;

M: latin1 stream-read-until
    latin1-stream stream-read-until >string ;

M: latin1 stream-readln
    latin1-stream stream-readln >string ;
