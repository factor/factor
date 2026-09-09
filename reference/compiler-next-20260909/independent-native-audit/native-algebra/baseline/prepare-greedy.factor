USING: vocabs.loader ;
<< "compiler.cfg.register-allocation.greedy" reload >>
USING: allocator-runtime-comparison compiler.cfg.register-allocation.greedy
kernel memory namespaces sequences ;
benchmark-words get-global length 28489 assert=
benchmark-words get-global [ \ hint-score eq? ] any? t assert=
benchmark-words get-global [ \ allocation-order eq? ] any? t assert=
"reference/compiler-next-20260909/prepared.image" save-image-and-exit
