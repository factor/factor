USING: kernel io.nonblocking io.unix.backend math.bitfields
unix io.files.unique.backend ;
IN: io.unix.files.unique

: open-unique-flags ( -- flags )
    { O_RDWR O_CREAT O_EXCL } flags ;

M: unix-io (make-unique-file) ( path -- duplex-stream )
    open-unique-flags file-mode open dup io-error
    <writer> ;

M: unix-io temporary-path ( -- path ) "/tmp" ;
