USING: io kernel parser sequences ;

"/library/unix/types.factor" run-resource

os "freebsd" = [
    "/library/unix/syscalls-freebsd.factor" run-resource 
] when

os "linux" = [
    "/library/unix/syscalls-linux.factor" run-resource 
] when

os "macosx" = [
    "/library/unix/syscalls-macosx.factor" run-resource 
] when
    
[
    "/library/unix/syscalls.factor"
    "/library/unix/io.factor"
    "/library/unix/sockets.factor"
    "/library/unix/files.factor"
] [
    run-resource 
] each
