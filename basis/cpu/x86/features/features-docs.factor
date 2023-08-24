! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations strings ;
IN: cpu.x86.features

HELP: instruction-count
{ $values
    { "n" number }
}
{ $description "The word returns the CPU's Timestamp Counter: " { $url "https://en.wikipedia.org/wiki/Time_Stamp_Counter" } "." } ;

ARTICLE: "cpu.x86.features" "CPU x86 features"
{ $vocab-link "cpu.x86.features" }
;

ABOUT: "cpu.x86.features"
