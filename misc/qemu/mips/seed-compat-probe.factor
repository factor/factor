! Copyright (C) 2026 Doug Coleman.
! Run against a seed lacking the new shared ABI predicate.
USING: io kernel namespaces parser prettyprint system words ;
"aapcs64-va-list-platform?" "cpu.architecture" lookup-word not t assert=
os "compat-old-os" set-global
cpu "compat-old-cpu" set-global
"resource:basis/bootstrap/compat/compat.factor" run-file
"aapcs64-va-list-platform?" "cpu.architecture" lookup-word >boolean t assert=
os "compat-old-os" get-global eq? t assert=
cpu "compat-old-cpu" get-global eq? t assert=
"Architecture hook old-seed migration preserves CPU/OS identities" print flush
