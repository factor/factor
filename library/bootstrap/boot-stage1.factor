! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: generic hashtables kernel lists math memory namespaces
parser prettyprint sequences io vectors words ;

"Bootstrap stage 1..." print

"/library/bootstrap/primitives.factor" run-resource

: pull-in ( list -- ) [ dup print parse-resource % ] each ;

! The make-list form creates a boot quotation
[
    [
        "/version.factor"

        "/library/stack.factor"
        "/library/combinators.factor"

        "/library/collections/sequences.factor"
        "/library/collections/arrays.factor"

        "/library/kernel.factor"

        "/library/math/math.factor"
        "/library/math/integer.factor"
        "/library/math/ratio.factor"
        "/library/math/float.factor"
        "/library/math/complex.factor"

        "/library/collections/cons.factor"
        "/library/collections/assoc.factor"
        "/library/collections/lists.factor"
        "/library/collections/vectors.factor"
        "/library/collections/strings.factor"
        "/library/collections/sbuf.factor"
        "/library/collections/sequences-epilogue.factor"
        "/library/collections/hashtables.factor"
        "/library/collections/namespaces.factor"
        "/library/collections/vectors-epilogue.factor"
        "/library/collections/slicing.factor"
        "/library/collections/strings-epilogue.factor"

        "/library/math/matrices.factor"

        "/library/words.factor"
        "/library/vocabularies.factor"
        "/library/errors.factor"
        "/library/continuations.factor"

        "/library/io/stream.factor"
        "/library/io/duplex-stream.factor"
        "/library/io/stdio.factor"
        "/library/io/lines.factor"
        "/library/io/string-streams.factor"
        "/library/io/c-streams.factor"
        "/library/io/files.factor"

        "/library/threads.factor"
        "/library/styles.factor"

        "/library/syntax/parse-numbers.factor"
        "/library/syntax/parse-words.factor"
        "/library/syntax/parse-errors.factor"
        "/library/syntax/parser.factor"
        "/library/syntax/parse-stream.factor"
        "/library/syntax/generic.factor"
        "/library/syntax/math.factor"
        "/library/syntax/parse-syntax.factor"
        
        "/library/alien/aliens.factor"
        
        "/library/syntax/unparser.factor"
        "/library/syntax/prettyprint.factor"

        "/library/tools/gensym.factor"
        "/library/tools/interpreter.factor"
        "/library/tools/debugger.factor"
        "/library/tools/memory.factor"

        "/library/inference/conditions.factor"
        "/library/inference/dataflow.factor"
        "/library/inference/values.factor"
        "/library/inference/inference.factor"
        "/library/inference/branches.factor"
        "/library/inference/words.factor"
        "/library/inference/stack.factor"
        "/library/inference/partial-eval.factor"
        
        "/library/compiler/assembler.factor"
        "/library/compiler/relocate.factor"
        "/library/compiler/xt.factor"
        "/library/compiler/optimizer.factor"
        "/library/compiler/vops.factor"
        "/library/compiler/linearizer.factor"
        "/library/compiler/intrinsics.factor"
        "/library/compiler/simplifier.factor"
        "/library/compiler/generator.factor"
        "/library/compiler/compiler.factor"

        "/library/alien/c-types.factor"
        "/library/alien/enums.factor"
        "/library/alien/structs.factor"
        "/library/alien/compiler.factor"
        "/library/alien/syntax.factor"

        "/library/cli.factor"
        
        "/library/tools/memory.factor"
    ] pull-in
] make-list

"object" [ "generic" ] search
"typemap" [ "generic" ] search
"builtins" [ "generic" ] search

vocabularies get [ "generic" off ] bind

reveal
reveal
reveal

[
    [
        boot
        
        "Rehashing hash tables..." print

        [ hashtable? ] instances
        [ dup hash-size 1 max swap set-bucket-count ] each
    
        "Building cross-reference database..." print
        
        recrossref
    ] %

    [
        "/library/generic/generic.factor"
        "/library/generic/slots.factor"
        "/library/generic/object.factor"
        "/library/generic/null.factor"
        "/library/generic/builtin.factor"
        "/library/generic/predicate.factor"
        "/library/generic/union.factor"
        "/library/generic/complement.factor"
        "/library/generic/tuple.factor"
    
        "/library/bootstrap/init.factor"
    ] pull-in

    [
        "Building generics..." print
    
        all-words [ generic? ] subset [ make-generic ] each
    ] %
] make-list

swap

[
    "/library/bootstrap/boot-stage2.factor" run-resource
]

append3

vocabularies get [
    "!syntax" get "syntax" set

    "syntax" get [
        cdr dup word? [
            "syntax" "vocabulary" set-word-prop
        ] [
            drop
        ] ifte
    ] hash-each
] bind

"!syntax" vocabularies get remove-hash

FORGET: pull-in
