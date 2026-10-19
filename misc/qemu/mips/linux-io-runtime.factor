USING: accessors alien.c-types alien.data byte-arrays classes.struct compiler.units
io kernel locals math memory namespaces sequences unix.ffi unix.linux.epoll unix.stat
unix.statfs.linux unix.statvfs.linux system ;
IN: mips.linux-io-runtime
: check-layouts ( -- )
    stat heap-size cpu mips32? 160 216 ? = [ "FAIL stat64 size" throw ] unless
    \ statfs64 heap-size cpu mips32? 96 128 ? = [ "FAIL statfs64 size" throw ] unless
    \ statvfs64 heap-size cpu mips32? 96 112 ? = [ "FAIL statvfs64 size" throw ] unless
    epoll-event heap-size 16 = [ "FAIL epoll_event size" throw ] unless
    "data" epoll-event offset-of 8 = [ "FAIL epoll_event data" throw ] unless
    utmpx heap-size 384 = [ "FAIL utmpx size" throw ] unless
    "ut_tv" utmpx offset-of 340 = [ "FAIL utmpx timeval" throw ] unless
    O_CREAT 256 = O_NONBLOCK 128 = and SOL_SOCKET 65535 = and
    SOCK_STREAM 2 = and SOCK_DGRAM 1 = and [ "FAIL MIPS flags" throw ] unless ;
:: check-native-stat ( -- )
    stat new :> st
    "/" st stat-func 0 = [ "FAIL native stat64" throw ] unless
    st st_mode>> S_IFMT bitand S_IFDIR = [ "FAIL stat64 mode" throw ] unless
    st st_size>> 0 >= [ "FAIL stat64 size field" throw ] unless
    \ statfs64 new :> fs
    "/" fs statfs64 0 = [ "FAIL native statfs64" throw ] unless
    fs f_bsize>> 0 > [ "FAIL statfs64 block size" throw ] unless
    fs f_blocks>> 0 > [ "FAIL statfs64 blocks" throw ] unless
    \ statvfs64 new :> vs
    "/" vs statvfs64 0 = [ "FAIL native statvfs64" throw ] unless
    vs f_bsize>> 0 > [ "FAIL statvfs64 block size" throw ] unless ;
:: check-native-file-socket ( -- )
    "mips-io-path" get :> path
    path O_WRONLY O_CREAT bitor O_TRUNC bitor 0o600 open64 :> fd
    fd 0 >= [ "FAIL native open64 create flags" throw ] unless
    fd B{ 1 2 3 4 } 4 unix.ffi:write 4 = [ "FAIL native write" throw ] unless
    fd close 0 = [ "FAIL native close" throw ] unless
    stat new :> st
    path st stat-func 0 = [ "FAIL native created-file stat" throw ] unless
    st st_size>> 4 = [ "FAIL created-file stat size" throw ] unless
    path unlink 0 = [ "FAIL native unlink" throw ] unless
    AF_INET SOCK_STREAM 0 socket :> sock
    sock 0 >= [ "FAIL MIPS socket type" throw ] unless
    sock SOL_SOCKET SO_REUSEADDR 1 int <ref> 4 setsockopt 0 = [ "FAIL MIPS socket option" throw ] unless
    sock F_SETFL O_NONBLOCK fcntl 0 = [ "FAIL MIPS nonblocking flag" throw ] unless
    sock F_GETFL 0 fcntl O_NONBLOCK bitand O_NONBLOCK = [ "FAIL native nonblocking result" throw ] unless
    sock close 0 = [ "FAIL socket close" throw ] unless
    EPOLL_CLOEXEC epoll_create1 :> ep
    ep 0 >= [ "FAIL epoll create" throw ] unless
    ep close 0 = [ "FAIL epoll close" throw ] unless ;
{ stat-func statfs64 statvfs64 open64 unix.ffi:write close unlink socket
  setsockopt fcntl epoll_create1 check-layouts check-native-stat check-native-file-socket } compile
check-layouts check-native-stat check-native-file-socket
"MIPS Linux native layouts/stat/file/socket passed" print flush
