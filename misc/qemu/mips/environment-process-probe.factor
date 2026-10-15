! Copyright (C) 2026 Doug Coleman.
! Run in an isolated full compiler/I/O image; do not save this probe heap.
USING: compiler.units io kernel parser vocabs vocabs.loader words ;
[
    "unix.process" forget-vocab
    "environment.unix" forget-vocab
    "environment" forget-vocab
] with-compilation-unit
"os-env" "environment" lookup-word not t assert=
"resource:basis/bootstrap/io/io.factor" run-file
"PATH" "os-env" "environment" lookup-word execute >boolean t assert=
"Fresh bootstrap.io environment/process load passed" print flush
