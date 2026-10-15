! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays io.launcher sequences system tools.test ;
IN: io.launcher.haiku.tests

! Use a fresh process so this negative cannot replace an active watcher.
! Reject auto-reaping, preserve ENOTSUP, and remove the failed Factor handle.
{ } [
    vm-path "-no-user-init" "-i=" image-path append
    "-e=USING: accessors assocs continuations io.launcher kernel libc locals namespaces tools.test unix.ffi ; QUALIFIED-WITH: unix.ffi native IN: native.registration.cleanup [let SIGCHLD native:SIG_IGN native:signal :> previous [ [ { \"/bin/sleep\" \"30\" } run-detached drop f ] [ errno>> ENOTSUP = ] recover processes get assoc-empty? and t assert= ] [ SIGCHLD previous native:signal drop ] finally ]"
    4array try-process
] unit-test
