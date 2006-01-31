USING: io kernel parser sequences ;

"/library/unix/types.factor" run-resource
"/library/unix/syscalls-" os ".factor" append3 run-resource

[
    "/library/unix/syscalls.factor"
    "/library/unix/io.factor"
    "/library/unix/sockets.factor"
    "/library/unix/files.factor"
] [
    run-resource 
] each
