USING: io kernel parser sequences ;

"/library/unix/types.factor" run-resource
"/library/unix/syscalls-" os ".factor" append3 run-resource

[
    "/library/io/unix/syscalls.factor"
    "/library/io/unix/io.factor"
    "/library/io/unix/sockets.factor"
    "/library/io/unix/files.factor"
] [
    run-resource 
] each
