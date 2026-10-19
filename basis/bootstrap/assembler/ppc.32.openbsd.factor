! PowerPC32 SysV uses linked frames, a four-byte LR slot, and direct code pointers.
USING: parser kernel sequences ;
IN: bootstrap.assembler.ppc

<< "resource:basis/bootstrap/assembler/ppc.32-common.factor" parse-file suffix! >> call
