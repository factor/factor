#!/usr/bin/env python3
from pathlib import Path
P=Path(__file__).resolve().parent
old=P.parent/'allocator-speed-crossarch-20260908/timing.factor'
s=old.read_text().replace('USING: alien.syntax','USING: alien alien.data alien.syntax')
anchor=':: sample ( word trial -- )'
definition=''':: installed-integer-path ( trial phase -- )
    benchmark-words get-global [ word-id
        { "allocator-runtime-comparison:integer-pressure"
          "allocator-runtime-comparison:integer-pressure-work"
          "math:+" ":fixnum=>+" } member? ] filter :> targets
    targets length 4 assert=
    targets [| target |
        target word-id :> id
        target word-code :> ( start end )
        start <alien> end start - memory>byte-array >array :> bytes
        H{ { "kind" "installed-code" } { "phase" phase }
           { "trial" trial } { "word" id }
           { "start-address" start } { "code-bytes" bytes } } emit
    ] each ;
'''
assert s.count(anchor)==1;s=s.replace(anchor,definition+anchor)
s=s.replace('    gc\n    compiler_instructions :> before','    gc\n    trial "before-batch" installed-integer-path\n    compiler_instructions :> before')
s=s.replace('    background 0 = [','    trial "after-batch" installed-integer-path\n    background 0 = [')
s=s.replace('    workloads [| word | word -1 sample ] each','    \\ integer-pressure-work -1 sample')
s=s.replace('workloads [| word | word trial sample ] each','\\ integer-pressure-work trial sample')
(P/'integer-same-process.factor').write_text(s)
