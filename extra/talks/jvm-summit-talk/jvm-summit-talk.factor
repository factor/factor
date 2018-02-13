! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup math math.private kernel sequences
slots.private ;
IN: talks.jvm-summit-talk

CONSTANT: jvm-summit-slides
{
    { $slide "Factor language implementation"
        "Goals: expressiveness, metaprogramming, performance"
        "We want a language for anything from scripting DSLs to high-performance numerics"
        "I assume you know a bit about compiler implementation: parser -> frontend -> optimizer -> codegen"
        { "This is " { $strong "not" } " a talk about the Factor language" }
        { "Go to " { $url "http://factorcode.org" } " to learn the language" }
    }
    { $slide "Why are dynamic languages slow?"
        "Branching and indirection!"
        "Runtime type checks and dispatch"
        "Integer overflow checks"
        "Boxed integers and floats"
        "Lots of allocation of temporary objects"
    }
    { $slide "Interactive development"
        "Code can be reloaded at any time"
        "Class hierarchy might change"
        "Slots may be added and removed"
        "Functions might be redefined"
    }
    { $slide "Factor's solution"
        "Factor implements most of the library in Factor"
        "Library contains very generic, high-level code"
        "Always compiles to native code"
        "Compiler removes unused generality from high-level code"
        "Inlining, specialization, partial evaluation"
        "And deoptimize when assumptions change"
    }
    { $slide "Introduction: SSA form"
        "Every identifier only has one global definition"
        {
            "Not SSA:"
            { $code
                "x = 1"
                "y = 2"
                "x = x + y"
                "if(z < 0)"
                "    t = x + y"
                "else"
                "    t = x - y"
                "print(t)"
            }
        }
    }
    { $slide "Introduction: SSA form"
        "Rename re-definitions and subsequent usages"
        {
            "Still not SSA:"
            { $code
                "x = 1"
                "y = 2"
                "x1 = x + y"
                "if(z < 0)"
                "    t = x1 + y"
                "else"
                "    t = x1 - y"
                "print(t)"
            }
        }
    }
    { $slide "Introduction: SSA form"
        "Introduce “φ functions” at control-flow merge points"
        {
            "This is SSA:"
            { $code
                "x = 1"
                "y = 2"
                "x1 = x + y"
                "if(z < 0)"
                "    t1 = x1 + y"
                "else"
                "    t2 = x1 - y"
                "t3 = φ(t1,t2)"
                "print(t3)"
            }
        }
    }
    { $slide "Why SSA form?"
        {
            "Def-use chains:"
            { $list
                "Defs-of: instructions that define a value"
                "Uses-of: instructions that use a value"
            }
            "With SSA, defs-of has exactly one element"
        }
    }
    { $slide "Def-use chains"
        "Simpler def-use makes analysis more accurate."
        {
            "Non-SSA example:"
            { $code
                "if(x < 0)"
                "    s = new Circle"
                "    a = area(s1)"
                "else"
                "    s = new Rectangle"
                "    a = area(s2)"
            }
        }
    }
    { $slide "Def-use chains"
        {
            "SSA example:"
            { $code
                "if(x < 0)"
                "    s1 = new Circle"
                "    a1 = area(s1)"
                "else"
                "    s2 = new Rectangle"
                "    a2 = area(s2)"
                "a = φ(a1,a2)"
            }

        }
    }
    { $slide "Factor compiler overview"
        "High-level SSA IR constructed from stack code"
        "High level optimizer transforms high-level IR"
        "Low-level SSA IR is constructed from high-level IR"
        "Low level optimizer transforms low-level IR"
        "Register allocator runs on low-level IR"
        "Machine IR is constructed from low-level IR"
        "Code generation"
    }
    { $slide "High-level optimizer"
        "Frontend: expands macros, inline higher order functions"
        "Propagation: inline methods, constant folding"
        "Escape analysis: unbox tuples"
        "Dead code elimination: clean up"
    }
    { $slide "Higher-order functions"
        "Almost all control flow is done with higher-order functions"
        { { $link if } ", " { $link times } ", " { $link each } }
        "Calling a block is an indirect jump"
        "Solution: inline higher order functions at the call site"
        "Inline the block body at the higher order call site in the function"
        "Record inlining in deoptimization database"
    }
    { $slide "Generic functions"
        "A generic function contains multiple method bodies"
        "Dispatches on the class of argument(s)"
        "In Factor, generic functions are single dispatch"
        "Almost equivalent to message passing"
    }
    { $slide "Tuple slot access"
        "Slot readers and writers are generic functions"
        "Generated automatically when you define a tuple class"
        { "The generated methods call " { $link slot } ", " { $link set-slot } " primitives" }
        "These primitives are not type safe; the generic dispatch performs the type checking for us"
        "If class of dispatch value known statically, inline method"
        "This may result in more methods inlining from additional specialization"
    }
    { $slide "Generic arithmetic"
        { { $link + } ", " { $link * } ", etc perform a double dispatch on arguments" }
        { "Fixed-precision integers (" { $link fixnum } "s) upgrade to " { $link bignum } "s automatically" }
        "Floats and complex numbers are boxed, heap-allocated"
        "Propagation of classes helps for floats"
        "But not for fixnums, because of overflow checks"
        "So we also propagate integer intervals"
        "Interval arithmetic: etc, [a,b] + [c,d] = [a+c,b+d]"
    }
    { $slide "Slot value propagation"
        "Complex numbers are even trickier"
        "We can have a complex number with integer components, float components"
        "Even if we inline complex arithmetic methods, still dispatching on components"
        "Solution: propagate slot info"
    }
    { $slide "Constraint propagation"
        "Contrieved example:"
        { $code
            "x = •"
            "b = isa(x,array)"
            "if(b)"
            "    a = length(x)"
            "else"
            "    b = length(x)"
            "c = φ(a,b)"
        }
        { "We should be able to inline the call to " { $snippet "length" } " in the true branch" }
    }
    { $slide "Constraint propagation"
        "We build a table:"
        { $code
            "b true => x is array"
            "b false => x is ~array"
        }
        { "In true branch, apply all " { $snippet "b true" } " constraints" }
        { "In false branch, apply all " { $snippet "b false" } " constraints" }
    }
    { $slide "Going further"
        "High-level optimizer eliminates some dispatch overhead and allocation"
        {
            { "Let's take a look at the " { $link float+ } " primitive" }
            { $list
                "No type checking anymore... but"
                "Loads two tagged pointers from operand stack"
                "Unboxes floats"
                "Adds two floats"
                "Boxes float result and perform a GC check"
            }
        }
    }
    { $slide "Low-level optimizer"
        "Frontend: construct LL SSA IR from HL SSA IR"
        "Alias analysis: remove redundant slot loads/stores"
        "Value numbering: simplify arithmetic"
        "Representation selection: eliminate boxing"
        "Dead code elimination: clean up"
        "Register allocation"
    }
    { $slide "Constructing low-level IR"
        { "Low-level IR is a " { $emphasis "control flow graph" } " of " { $emphasis "basic blocks" } }
        "A basic block is a list of instructions"
        "Register-based IR; infinite, uniform register file"
        { "Instructions:"
            { $list
                "Subroutine calls"
                "Machine arithmetic"
                "Load/store values on operand stack"
                "Box/unbox values"
            }
        }
    }
    { $slide "Inline allocation and GC checks"
        {
            "Allocation of small objects can be done in a few instructions:"
            { $list
                "Bump allocation pointer"
                "Write object header"
                "Fill in payload"
            }
        }
        "Multiple allocations in the same basic block only need a single GC check; saves on a conditional branch"
    }
    { $slide "Alias analysis"
        "Factor constructors are just ordinary functions"
        { "They call a primitive constructor: " { $link new } }
        "When a new object is constructed, it has to be initialized"
        "... but the user's constructor probably fills in all the slots again with actual values"
        "Local alias analysis eliminates redundant slot loads and stores"
    }
    { $slide "Value numbering"
        { "A form of " { $emphasis "redundancy elimination" } }
        "Requires use of SSA form in order to work"
        "Define an equivalence relation over SSA values"
        "Assign a “value number” to each SSA value"
        "If two values have the same number, they will always be equal at runtime"
    }
    { $slide "Types of value numbering"
        "Many variations: algebraic simplifications, various rewrite rules can be tacked on"
        "Local value numbering: in basic blocks"
        "Global value numbering: entire procedure"
        "Factor only does local value numbering"
    }
    { $slide "Value graph and expressions"
        { $table
            {
                {
                    "Basic block:"
                    { $code
                        "x = •"
                        "y = •"
                        "a = x + 1"
                        "b = a + 1"
                        "c = x + 2"
                        "d = b - c"
                        "e = y + d"
                    }
                }
                {
                    "Value numbers:"
                    { $code
                        "V1: •"
                        "V2: •"
                        "V3: 1"
                        "V4: 2"
                        "V5: (V1 + V3)"
                        "V6: (V5 + V3)"
                        "V7: (V3 + V4)"
                        "V8: (V6 - V7)"
                        "V9: (V2 + V8)"
                    }
                }
            }
        }
    }
    { $slide "Expression simplification"
        {
            "Constant folding: if V1 and V2 are constants "
            { $snippet "(V1 op V2)" }
            " can be evaluated at compile-time"
        }
        {
            "Reassociation: if V2 and V3 are constants "
            { $code "((V1 op V2) op V3) => (V1 op (V2 op V3))" }
        }
        {
            "Algebraic identities: if V2 is constant 0, "
            { $code "(V1 + V2) => V1" }
        }
        {
            "Strength reduction: if V2 is a constant power of two, "
            { $code "(V1 * V2) => (V1 << log2(V2))" }
        }
        "etc, etc, etc"
    }
    { $slide "Representation selection overview"
        "Floats and SIMD vectors need to be boxed"
        "Representation: tagged pointer, unboxed float, unboxed SIMD value..."
        "When IR is built, no boxing or unboxing instructions inserted"
        "Representation selection pass makes IR consistent"
    }
    { $slide "Representation selection algorithm"
        {
            "For each SSA value:"
            { $list
                "Compute possible representations"
                "Compute cost of each representation"
                "Pick representation with minimum cost"
            }
        }
        {
            "For each instruction:"
            { $list
                "If it expects a value to be in a different representation, insert box or unbox code"
            }
        }
    }
    { $slide "Register allocation"
        "Linear scan algorithm used in Java HotSpot Client"
        "Described in Christian Wimmer's masters thesis"
        "Works fine on x86-64, not too great on x86-32"
        "Good enough since basic blocks tend to be short, with lots of procedure calls"
        "Might switch to graph coloring eventually"
    }
    { $slide "Compiler tools"
        "Printing high level IR"
        "Printing low level IR"
        "Disassembly"
        "Display call tree"
        "Display control flow graph"
        "Display dominator tree"
    }
}

: jvm-summit-talk ( -- )
    jvm-summit-slides "JVM Summit talk" slides-window ;

MAIN: jvm-summit-talk
