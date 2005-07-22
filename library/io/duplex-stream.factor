! Combine an input and output stream into one, and flush the
! stream more often.
USING: io kernel ;

TUPLE: duplex-stream in out flush? ;

M: duplex-stream stream-flush
    duplex-stream-out stream-flush ;

M: duplex-stream stream-finish
    dup duplex-stream-flush?
    [ duplex-stream-out stream-flush ] [ drop ] ifte ;

M: duplex-stream stream-readln
    duplex-stream-in stream-readln ;

M: duplex-stream stream-read1
    duplex-stream-in stream-read1 ;

M: duplex-stream stream-read
    duplex-stream-in stream-read ;

M: duplex-stream stream-write1
    duplex-stream-out stream-write1 ;

M: duplex-stream stream-write-attr
    duplex-stream-out stream-write-attr ;

M: duplex-stream stream-close
    #! The output stream is closed first, in case both streams
    #! are attached to the same file descriptor, the output
    #! buffer needs to be flushed before we close the fd.
    dup
    duplex-stream-out stream-close
    duplex-stream-in stream-close ;

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;
