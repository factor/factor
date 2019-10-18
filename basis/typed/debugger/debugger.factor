! (c)Joe Groff bsd license
USING: typed compiler.cfg.debugger compiler.tree.debugger
tools.disassembler words ;
IN: typed.debugger

M: typed-word test-builder
    "typed-word" word-prop test-builder ;

: typed-optimized. ( word -- )
    "typed-word" word-prop optimized. ;

M: typed-word disassemble ( word -- )
    "typed-word" word-prop disassemble ;
