USE: parser
<< "resource:basis/bootstrap/compat/compat.factor" run-file
   "resource:basis/compiler/constants/constants.factor" run-file >>
USING: bootstrap.image.private cpu.m88k hashtables io kernel namespaces
parser system ;
H{ } clone special-objects set
H{ } clone sub-primitives set
 "resource:basis/bootstrap/assembler/m88k.32.factor" run-file
 "m88k bootstrap template prefix loaded" print
USING: arrays compiler.constants cpu.m88k.assembler io.encodings.binary io.files io.pathnames command-line make sequences math math.private kernel kernel.private ;
IN: bootstrap.assembler.m88k
: save-boot-code ( bytes name -- ) command-line get first prepend-path binary set-file-contents ;
: boot-code ( primitive -- bytes ) sub-primitives get at third second ;
[ \ fixnum+fast boot-code % RET ] B{ } make "boot-add.bin" save-boot-code
[ \ fixnum*fast boot-code % RET ] B{ } make "boot-mul.bin" save-boot-code
[ \ swap boot-code % RET ] B{ } make "boot-swap.bin" save-boot-code
JIT-IF special-objects get at second "boot-if.bin" save-boot-code
