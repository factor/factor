! Emit actual optimizer native double argument, return and stack assignment.
USING: arrays byte-arrays command-line cpu.architecture cpu.hppa cpu.hppa.assembler
cpu.hppa.assembler.registers io.encodings.binary io.files io.pathnames kernel
layouts make namespaces sequences system ;
IN: cpu.hppa.native-float-emit
4 \ cell set
: save-code ( bytes name -- ) command-line get first prepend-path binary set-file-contents ;
hppa.32 \ cpu [
    [ 16 %prologue F8 arg2 %integer>float F9 arg3 %integer>float
      arg1 f F8 double-rep F5 3array F9 double-rep F7 3array 2array
      { } F4 double-rep F4 3array 1array { } 0 16 f %alien-indirect
      16 %epilogue RET ] B{ } make "hppa-indirect-double.bin" save-code
    [ 16 %prologue F8 arg3 %integer>float
      arg1 f arg2 int-rep arg1 3array F8 double-rep F7 3array 2array
      arg2 int-rep 16 4 4array 1array F4 double-rep F4 3array 1array { } 0 20 f %alien-indirect
      16 %epilogue RET ] B{ } make "hppa-indirect-mixed.bin" save-code
] with-variable
