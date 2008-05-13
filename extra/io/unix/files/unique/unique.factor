USING: kernel io.ports io.unix.backend math.bitfields
unix io.files.unique.backend system ;
IN: io.unix.files.unique

: open-unique-flags ( -- flags )
    { O_RDWR O_CREAT O_EXCL } flags ;

M: unix (make-unique-file) ( path -- )
    open-unique-flags file-mode open dup io-error close ;

M: unix temporary-path ( -- path ) "/tmp" ;
