USING: kernel io io.files io.pathnames io.monitors io.encodings.utf8 ;
IN: log-viewer

: read-lines ( stream -- )
    dup stream-readln dup
    [ print read-lines ] [ 2drop flush ] if ;

: tail-file-loop ( stream monitor -- )
    dup next-change drop over read-lines tail-file-loop ;

: tail-file ( file -- )
    dup utf8 <file-reader> dup read-lines
    swap parent-directory f <monitor>
    tail-file-loop ;
