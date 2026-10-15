! NetBSD PowerPC32 SysV uses the shared direct-code-pointer bootstrap.
USING: parser kernel sequences ;
IN: bootstrap.assembler.ppc

<< "resource:basis/bootstrap/assembler/ppc.32-common.factor" parse-file suffix! >> call
