USING: io kernel parser sequences ;

"/library/unix/types.factor" dup print run-resource

os "freebsd" = [
    "/library/unix/syscalls-freebsd.factor" dup print run-resource 
] when

os "linux" = [
    "/library/unix/syscalls-linux.factor" dup print run-resource 
] when

os "macosx" = [
    "/library/unix/syscalls-macosx.factor" dup print run-resource 
] when
    
[
    "/library/unix/syscalls.factor"
    "/library/unix/io.factor"
    "/library/unix/sockets.factor"
    "/library/unix/files.factor"
] [
    dup print run-resource 
] each
