USING: help.markup help.syntax literals multiline sequences splitting ;
IN: compiler.cfg.instructions.syntax

<<
STRING: parse-insn-slot-specs-code
USING: compiler.cfg.instructions.syntax prettyprint splitting ;
"use: src/int-rep temp: temp/int-rep" split-words parse-insn-slot-specs .
;

STRING: parse-insn-slot-specs-result
{
    T{ insn-slot-spec
        { type use }
        { name "src" }
        { rep int-rep }
    }
    T{ insn-slot-spec
        { type temp }
        { name "temp" }
        { rep int-rep }
    }
}
;
>>

HELP: parse-insn-slot-specs
{ $values
  { "seq" "a " { $link sequence } " of tokens" }
  { "specs" "a " { $link sequence } " of " { $link insn-slot-spec } " items." }
}
{ $description "Parses a sequence of tokens into a sequence of instruction slot specifiers." }
{ $examples
  { $example $[ parse-insn-slot-specs-code parse-insn-slot-specs-result ] }
} ;
