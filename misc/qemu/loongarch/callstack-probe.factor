USING: kernel kernel.private io continuations memory system ;
IN: scratchpad
: stack-roundtrip ( -- ) [ get-callstack gc set-callstack ] call ;
stack-roundtrip
"LoongArch captured-stack GC/restore PASS" print flush
0 (exit)
