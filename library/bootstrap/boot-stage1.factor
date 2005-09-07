! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: generic hashtables kernel kernel-internals
lists math memory namespaces parser prettyprint
sequences io vectors words ;

"Bootstrap stage 1..." print

"/library/bootstrap/primitives.factor" run-resource

! The [ ] make form creates a boot quotation
[
    [
        [ hashtable? ] instances
        [ dup hash-size 1 max swap set-bucket-count ] each

        boot
    ] %

    {
        "/version.factor"

        "/library/generic/early-generic.factor"

        "/library/kernel.factor"

        "/library/collections/sequences.factor"
        "/library/collections/arrays.factor"

        "/library/math/math.factor"
        "/library/math/integer.factor"
        "/library/math/ratio.factor"
        "/library/math/float.factor"
        "/library/math/complex.factor"
        "/library/math/random.factor"

        "/library/collections/growable.factor"
        "/library/collections/cons.factor"
        "/library/collections/virtual-sequences.factor"
        "/library/collections/sequence-combinators.factor"
        "/library/collections/sequences-epilogue.factor"
        "/library/collections/strings.factor"
        "/library/collections/sbuf.factor"
        "/library/collections/assoc.factor"
        "/library/collections/lists.factor"
        "/library/collections/vectors.factor"
        "/library/collections/hashtables.factor"
        "/library/collections/namespaces.factor"
        "/library/collections/sequence-eq.factor"
        "/library/collections/slicing.factor"
        "/library/collections/sequence-sort.factor"
        "/library/collections/strings-epilogue.factor"
        "/library/collections/tree-each.factor"
        "/library/collections/queues.factor"

        "/library/math/matrices.factor"
        "/library/math/parse-numbers.factor"

        "/library/words.factor"
        "/library/vocabularies.factor"
        "/library/errors.factor"
        "/library/continuations.factor"
        "/library/styles.factor"

        "/library/io/stream.factor"
        "/library/io/duplex-stream.factor"
        "/library/io/stdio.factor"
        "/library/io/lines.factor"
        "/library/io/string-streams.factor"
        "/library/io/c-streams.factor"
        "/library/io/files.factor"
        "/library/io/binary.factor"

        "/library/syntax/parse-words.factor"
        "/library/syntax/parse-errors.factor"
        "/library/syntax/parser.factor"
        "/library/syntax/parse-stream.factor"

        "/library/generic/generic.factor"
        "/library/generic/standard-combination.factor"
        "/library/generic/slots.factor"
        "/library/generic/math-combination.factor"
        "/library/generic/predicate.factor"
        "/library/generic/union.factor"
        "/library/generic/tuple.factor"

        "/library/syntax/generic.factor"
        "/library/syntax/parse-syntax.factor"
        
        "/library/alien/aliens.factor"
        
        "/library/syntax/prettyprint.factor"

        "/library/io/logging.factor"

        "/library/tools/interpreter.factor"
        "/library/tools/debugger.factor"
        "/library/tools/memory.factor"
        "/library/tools/listener.factor"
        "/library/tools/walker.factor"
        "/library/tools/jedit.factor"
        "/library/tools/annotations.factor"
        "/library/tools/inspector.factor"

        "/library/test/test.factor"
        
        "/library/syntax/see.factor"

        "/library/threads.factor"
        
        "/library/tools/telnetd.factor"

        "/library/bootstrap/image.factor"

        "/library/compiler/architecture.factor"

        "/library/inference/shuffle.factor"
        "/library/inference/dataflow.factor"
        "/library/inference/inference.factor"
        "/library/inference/branches.factor"
        "/library/inference/words.factor"
        "/library/inference/recursive-values.factor"
        "/library/inference/class-infer.factor"
        "/library/inference/kill-literals.factor"
        "/library/inference/split-nodes.factor"
        "/library/inference/optimizer.factor"
        "/library/inference/inline-methods.factor"
        "/library/inference/known-words.factor"
        "/library/inference/stack.factor"
        "/library/inference/call-optimizers.factor"
        "/library/inference/print-dataflow.factor"

        "/library/compiler/assembler.factor"
        "/library/compiler/relocate.factor"
        "/library/compiler/xt.factor"
        "/library/compiler/vops.factor"
        "/library/compiler/linearizer.factor"
        "/library/compiler/stack.factor"
        "/library/compiler/intrinsics.factor"
        "/library/compiler/simplifier.factor"
        "/library/compiler/generator.factor"
        "/library/compiler/compiler.factor"

        "/library/alien/c-types.factor"
        "/library/alien/structs.factor"
        "/library/alien/compiler.factor"
        "/library/alien/syntax.factor"

        "/library/cli.factor"
        
        "/library/bootstrap/init.factor"
    } [ dup print parse-resource % ] each
    
    [ "/library/bootstrap/boot-stage2.factor" run-resource ] %
] [ ] make

vocabularies get [
    "!syntax" get "syntax" set

    "syntax" get hash-values [ word? ] subset
    [ "syntax" swap set-word-vocabulary ] each
] bind

"!syntax" vocabularies get remove-hash
