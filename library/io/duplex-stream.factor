! Combine an input and output stream into one, and flush the
! stream more often.
USING: io kernel ;

TUPLE: duplex-stream in out flush? ;

M: duplex-stream stream-flush
    duplex-stream-out stream-flush ;

M: duplex-stream stream-auto-flush
    dup duplex-stream-flush?
    [ duplex-stream-out stream-flush ] [ drop ] ifte ;

M: duplex-stream stream-readln
    duplex-stream-in stream-readln ;

M: duplex-stream stream-read
    duplex-stream-in stream-read ;

M: duplex-stream stream-read1
    duplex-stream-in stream-read1 ;

M: duplex-stream stream-write-attr
    duplex-stream-out stream-write-attr ;

M: duplex-stream stream-close
    duplex-stream-out stream-close ;

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;
