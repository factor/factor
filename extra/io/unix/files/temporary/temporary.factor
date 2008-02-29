USING: kernel io.nonblocking io.unix.backend math.bitfields
unix io.files.temporary.backend ;
IN: io.unix.files.temporary

: open-temporary-flags ( -- flags )
    { O_RDWR O_CREAT O_EXCL } flags ;

M: unix-io (temporary-file) ( path -- duplex-stream )
    open-temporary-flags file-mode open dup io-error
    <writer> ;

M: unix-io temporary-path ( -- path ) "/tmp" ;
