! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: image
USING: errors generic hashtables io kernel kernel-internals
lists math memory namespaces parser prettyprint sequences
vectors words ;

"Bootstrap stage 1..." print flush

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
        
        "/library/io/styles.factor"
        "/library/io/stream.factor"
        "/library/io/duplex-stream.factor"
        "/library/io/stdio.factor"
        "/library/io/null-stream.factor"
        "/library/io/plain-stream.factor"
        "/library/io/lines.factor"
        "/library/io/string-streams.factor"
        "/library/io/c-streams.factor"
        "/library/io/files.factor"
        "/library/io/binary.factor"

        "/library/syntax/parser.factor"

        "/library/generic/generic.factor"
        "/library/generic/standard-combination.factor"
        "/library/generic/slots.factor"
        "/library/generic/math-combination.factor"
        "/library/generic/tuple.factor"
        
        "/library/alien/aliens.factor"
        
        "/library/syntax/prettyprint.factor"
        "/library/syntax/see.factor"

        "/library/tools/interpreter.factor"
        
        "/library/help/database.factor"
        "/library/help/stylesheet.factor"
        "/library/help/help.factor"
        "/library/help/markup.factor"
        "/library/help/word-help.factor"
        "/library/help/syntax.factor"
        
        "/library/tools/describe.factor"
        "/library/tools/debugger.factor"

        "/library/syntax/parse-stream.factor"
        
        "/library/tools/memory.factor"
        "/library/tools/listener.factor"
        "/library/tools/walker.factor"

        "/library/tools/annotations.factor"
        "/library/tools/inspector.factor"
        
        "/library/test/test.factor"

        "/library/threads.factor"
        
        "/library/io/server.factor"
        "/library/tools/jedit.factor"

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
        "/library/compiler/vops.factor"
        "/library/compiler/linearizer.factor"
        "/library/compiler/xt.factor"
        "/library/compiler/stack.factor"
        "/library/compiler/intrinsics.factor"
        "/library/compiler/basic-blocks.factor"
        "/library/compiler/generator.factor"
        "/library/compiler/compiler.factor"

        "/library/alien/c-types.factor"
        "/library/alien/structs.factor"
        "/library/alien/alien-invoke.factor"
        "/library/alien/alien-callback.factor"
        "/library/alien/syntax.factor"
        "/library/alien/malloc.factor"
        
        "/library/io/buffer.factor"

        "/library/cli.factor"
        
        "/library/bootstrap/init.factor"
        
        ! This must be the last file of parsing words loaded
        "/library/syntax/parse-syntax.factor"

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

        "/library/ui/timers.factor"
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
        "/library/ui/paragraphs.factor"
        "/library/ui/panes.factor"
        "/library/ui/outliner.factor"
        "/library/ui/listener.factor"
        "/library/ui/commands.factor"
        "/library/ui/presentations.factor"
        "/library/ui/ui.factor"

        "/library/help/commands.factor"

        "/library/continuations.facts"
        "/library/errors.facts"
        "/library/kernel.facts"
        "/library/threads.facts"
        "/library/vocabularies.facts"
        "/library/words.facts"
        "/library/collections/growable.facts"
        "/library/collections/arrays.facts"
        "/library/collections/hashtables.facts"
        "/library/collections/namespaces.facts"
        "/library/collections/queues.facts"
        "/library/collections/sbuf.facts"
        "/library/collections/sequence-combinators.facts"
        "/library/collections/sequence-eq.facts"
        "/library/collections/sequence-sort.facts"
        "/library/collections/sequences-epilogue.facts"
        "/library/collections/sequences.facts"
        "/library/collections/slicing.facts"
        "/library/collections/strings.facts"
        "/library/collections/tree-each.facts"
        "/library/collections/vectors.facts"
        "/library/collections/virtual-sequences.facts"
        "/library/generic/early-generic.facts"
        "/library/generic/generic.facts"
        "/library/generic/math-combination.facts"
        "/library/generic/slots.facts"
        "/library/generic/standard-combination.facts"
        "/library/generic/tuple.facts"
        "/library/io/binary.facts"
        "/library/io/buffer.facts"
        "/library/io/c-streams.facts"
        "/library/io/duplex-stream.facts"
        "/library/io/files.facts"
        "/library/io/lines.facts"
        "/library/io/plain-stream.facts"
        "/library/io/server.facts"
        "/library/io/stdio.facts"
        "/library/io/stream.facts"
        "/library/io/string-streams.facts"
        "/library/io/styles.facts"
        "/library/math/arc-trig-hyp.facts"
        "/library/math/complex.facts"
        "/library/math/constants.facts"
        "/library/math/float.facts"
        "/library/math/integer.facts"
        "/library/math/math.facts"
        "/library/math/parse-numbers.facts"
        "/library/math/pow.facts"
        "/library/math/random.facts"
        "/library/math/ratio.facts"
        "/library/math/trig-hyp.facts"
        "/library/math/vectors.facts"
        "/library/syntax/parse-stream.facts"
        "/library/syntax/parser.facts"
        "/library/syntax/parse-syntax.facts"
        "/library/syntax/prettyprint.facts"
        "/library/syntax/see.facts"
        "/library/tools/debugger.facts"

        "/doc/handbook/collections.facts"
        "/doc/handbook/dataflow.facts"
        "/doc/handbook/handbook.facts"
        "/doc/handbook/math.facts"
        "/doc/handbook/objects.facts"
        "/doc/handbook/parser.facts"
        "/doc/handbook/prettyprinter.facts"
        "/doc/handbook/sequences.facts"
        "/doc/handbook/streams.facts"
        "/doc/handbook/syntax.facts"
        "/doc/handbook/tutorial.facts"
        "/doc/handbook/words.facts"

        "/library/bootstrap/image.factor"
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
                    "/library/compiler/amd64/generator.factor"
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

"Building generic words..." print flush

all-words [ generic? ] subset [ make-generic ] each
