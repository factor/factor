! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: errors generic hashtables io kernel kernel-internals
lists math memory namespaces parser prettyprint sequences
vectors words ;

"Bootstrap stage 1..." print

"/library/bootstrap/primitives.factor" run-resource

! The [ ] make form creates a boot quotation
[
    \ boot ,

    {
        "/version.factor"

        "/library/generic/early-generic.factor"

        "/library/kernel.factor"

        "/library/math/math.factor"
        "/library/math/integer.factor"
        "/library/math/ratio.factor"
        "/library/math/float.factor"
        "/library/math/complex.factor"

        "/library/collections/sequences.factor"
        "/library/collections/growable.factor"
        "/library/collections/cons.factor"
        "/library/collections/virtual-sequences.factor"
        "/library/collections/sequence-combinators.factor"
        "/library/collections/sequences-epilogue.factor"
        "/library/collections/arrays.factor"
        "/library/collections/strings.factor"
        "/library/collections/sbuf.factor"
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

        "/library/math/random.factor"
        "/library/math/constants.factor"
        "/library/math/pow.factor"
        "/library/math/trig-hyp.factor"
        "/library/math/arc-trig-hyp.factor"
        "/library/math/vectors.factor"
        "/library/math/parse-numbers.factor"

        "/library/words.factor"
        "/library/vocabularies.factor"
        "/library/continuations.factor"
        "/library/errors.factor"
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
        "/library/generic/tuple.factor"
        
        "/library/alien/aliens.factor"
        
        "/library/syntax/prettyprint.factor"
        "/library/syntax/see.factor"

        "/library/tools/interpreter.factor"
        
        "/library/tools/describe.factor"
        "/library/tools/debugger.factor"
        "/library/tools/memory.factor"
        "/library/tools/listener.factor"
        "/library/tools/walker.factor"

        "/library/tools/annotations.factor"
        "/library/tools/inspector.factor"

        "/library/test/test.factor"

        "/library/threads.factor"
        
        "/library/io/server.factor"
        "/library/tools/jedit.factor"

        "/library/bootstrap/image.factor"

        "/library/compiler/architecture.factor"

        "/library/inference/shuffle.factor"
        "/library/inference/dataflow.factor"
        "/library/inference/inference.factor"
        "/library/inference/branches.factor"
        "/library/inference/words.factor"
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
        "/library/compiler/xt.factor"
        "/library/compiler/vops.factor"
        "/library/compiler/linearizer.factor"
        "/library/compiler/stack.factor"
        "/library/compiler/intrinsics.factor"
        "/library/compiler/basic-blocks.factor"
        "/library/compiler/generator.factor"
        "/library/compiler/compiler.factor"

        "/library/alien/c-types.factor"
        "/library/alien/structs.factor"
        "/library/alien/compiler.factor"
        "/library/alien/syntax.factor"
        "/library/alien/malloc.factor"
        
        "/library/io/buffer.factor"

        "/library/syntax/generic.factor"

        "/library/cli.factor"
        
        "/library/bootstrap/init.factor"
        
        "/library/sdl/sdl.factor"
        "/library/sdl/sdl-video.factor"
        "/library/sdl/sdl-event.factor"
        "/library/sdl/sdl-keysym.factor"
        "/library/sdl/sdl-keyboard.factor"
        "/library/sdl/sdl-utils.factor"

        "/library/opengl/gl.factor"
        "/library/opengl/glu.factor"
        "/library/opengl/opengl-utils.factor"

        "/library/freetype/freetype.factor"
        "/library/freetype/freetype-gl.factor"

        "/library/ui/gadgets.factor"
        "/library/ui/layouts.factor"
        "/library/ui/hierarchy.factor"
        "/library/ui/paint.factor"
        "/library/ui/gestures.factor"
        "/library/ui/theme.factor"
        "/library/ui/hand.factor"
        "/library/ui/frames.factor"
        "/library/ui/world.factor"
        "/library/ui/events.factor"
        "/library/ui/borders.factor"
        "/library/ui/labels.factor"
        "/library/ui/buttons.factor"
        "/library/ui/line-editor.factor"
        "/library/ui/sliders.factor"
        "/library/ui/scrolling.factor"
        "/library/ui/menus.factor"
        "/library/ui/editors.factor"
        "/library/ui/splitters.factor"
        "/library/ui/incremental.factor"
        "/library/ui/panes.factor"
        "/library/ui/books.factor"
        "/library/ui/outliner.factor"
        "/library/ui/presentations.factor"
        "/library/ui/listener.factor"
        "/library/ui/ui.factor"

        "/library/help/database.factor"
        "/library/help/markup.factor"
        "/library/help/help.factor"
        "/library/help/tutorial.factor"
        "/library/help/syntax.factor"

        "/library/syntax/parse-syntax.factor"
    } [ parse-resource % ] each
    
    architecture get {
        {
            [ dup "x86" = ] [
                {
                    "/library/compiler/x86/assembler.factor"
                    "/library/compiler/x86/architecture.factor"
                    "/library/compiler/x86/generator.factor"
                    "/library/compiler/x86/slots.factor"
                    "/library/compiler/x86/stack.factor"
                    "/library/compiler/x86/fixnum.factor"
                    "/library/compiler/x86/alien.factor"
                }
            ]
        } {
            [ dup "ppc" = ] [
                {
                    "/library/compiler/ppc/assembler.factor"
                    "/library/compiler/ppc/architecture.factor"
                    "/library/compiler/ppc/generator.factor"
                    "/library/compiler/ppc/slots.factor"
                    "/library/compiler/ppc/stack.factor"
                    "/library/compiler/ppc/fixnum.factor"
                    "/library/compiler/ppc/alien.factor"
                }
            ]
        } {
            [ dup "amd64" = ] [
                {
                    "/library/compiler/x86/assembler.factor"
                    "/library/compiler/amd64/assembler.factor"
                    "/library/compiler/amd64/architecture.factor"
                    "/library/compiler/x86/generator.factor"
                    "/library/compiler/x86/slots.factor"
                    "/library/compiler/x86/stack.factor"
                    "/library/compiler/x86/fixnum.factor"
                    "/library/compiler/amd64/alien.factor"
                }
            ]
        }
    } cond [ parse-resource % ] each drop
    
    [
        "/library/bootstrap/boot-stage2.factor" run-resource
        [ print-error die ] recover
    ] %
] [ ] make

vocabularies get [
    "!syntax" get "syntax" set

    "syntax" get hash-values [ word? ] subset
    [ "syntax" swap set-word-vocabulary ] each
] bind

"!syntax" vocabularies get remove-hash

H{ } clone crossref set
recrossref
