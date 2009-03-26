! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup ;
IN: chicago-talk

CONSTANT: chicago-slides
{
{ $slide "factor"

{ $url "http://factorcode.org" }

}
{ $slide "goals"

"high level language"
"expressive and extensible"
"reasonable performance"
"interactive development with arbitrary redefinition"
"standalone app deployment (strip out compiler and REPL)"

}
{ $slide "challenges"

"higher-order functions"
"dynamic typing"
"memory allocation"
"float boxing/unboxing"
"integer overflow checks"
"user-defined abstractions"

}
{ $slide "implementation"

"VM: 12 kloc of C, library: >100 kloc of Factor"
"generational copying garbage collection, card marking write barrier"
"full continuations, tail calls"
"simple non-optimizing “bootstrap” compiler"
"optimizing compiler"

}
{ $slide "optimizing compiler"

"about 12,000 lines of Factor code"
"targets x86-32, x86-64, PowerPC"
"factor code ⇒ high-level SSA ⇒ low-level SSA ⇒ machine code"

}
{ $slide "high-level optimizer"

"macro expansion, defunctionalization"
"type and interval inference, sparse conditional constant propagation, method inlining"
"escape analysis and tuple unboxing"

}
{ $slide "low-level optimizer"

"alias analysis, value numbering, write barrier elimination"
"linear scan register allocation"

}
}

: chicago-talk ( -- ) chicago-slides slides-window ;

MAIN: chicago-talk