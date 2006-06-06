! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: image
USING: errors generic hashtables io kernel kernel-internals
math memory namespaces parser prettyprint sequences
vectors words ;

"Bootstrap stage 1..." print flush

"/library/bootstrap/primitives.factor" run-resource

: parse-resource* ( path -- )
    [ parse-resource ] catch [
        { { "Parse file again" t } } condition drop
        parse-resource*
    ] when* ;

: if-arch ( arch seq -- )
    architecture get rot member?
    [ [ parse-resource* % ] each ] [ drop ] if ;

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
        "/library/collections/virtual-sequences.factor"
        "/library/collections/sequence-combinators.factor"
        "/library/collections/arrays.factor"
        "/library/collections/sequences-epilogue.factor"
        "/library/collections/strings.factor"
        "/library/collections/sbuf.factor"
        "/library/collections/vectors.factor"
        "/library/collections/hashtables.factor"
        "/library/collections/namespaces.factor"
        "/library/collections/slicing.factor"
        "/library/collections/sequence-sort.factor"
        "/library/collections/flatten.factor"
        "/library/collections/queues.factor"
        "/library/collections/graphs.factor"

        "/library/quotations.factor"

        "/library/math/random.factor"
        "/library/math/constants.factor"
        "/library/math/pow.factor"
        "/library/math/trig-hyp.factor"
        "/library/math/arc-trig-hyp.factor"
        "/library/math/vectors.factor"
        "/library/math/parse-numbers.factor"

        "/library/words.factor"
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

        "/library/syntax/early-parser.factor"

        "/library/generic/generic.factor"
        "/library/generic/standard-combination.factor"
        "/library/generic/slots.factor"
        "/library/generic/math-combination.factor"
        "/library/generic/tuple.factor"
        
        "/library/compiler/alien/aliens.factor"
        
        "/library/syntax/prettyprint.factor"
        "/library/syntax/see.factor"
        "/library/syntax/parser.factor"

        "/library/tools/interpreter.factor"
        
        "/library/help/stylesheet.factor"
        "/library/help/help.factor"
        "/library/help/markup.factor"
        "/library/help/word-help.factor"
        "/library/help/crossref.factor"
        "/library/help/syntax.factor"
        
        "/library/tools/describe.factor"
        "/library/tools/debugger.factor"
        
        "/library/syntax/parse-stream.factor"

        "/library/tools/memory.factor"
        "/library/tools/listener.factor"
        "/library/tools/inspector.factor"
        "/library/tools/walker.factor"

        "/library/tools/annotations.factor"
        
        "/library/test/test.factor"

        "/library/threads.factor"
        
        "/library/io/server.factor"
        "/library/tools/jedit.factor"

        "/library/compiler/inference/shuffle.factor"
        "/library/compiler/inference/dataflow.factor"
        "/library/compiler/inference/inference.factor"
        "/library/compiler/inference/branches.factor"
        "/library/compiler/inference/words.factor"
        "/library/compiler/inference/stack.factor"
        "/library/compiler/inference/known-words.factor"

        "/library/compiler/optimizer/specializers.factor"
        "/library/compiler/optimizer/class-infer.factor"
        "/library/compiler/optimizer/kill-literals.factor"
        "/library/compiler/optimizer/optimizer.factor"
        "/library/compiler/optimizer/inline-methods.factor"
        "/library/compiler/optimizer/call-optimizers.factor"
        "/library/compiler/optimizer/print-dataflow.factor"

        "/library/compiler/generator/architecture.factor"
        "/library/compiler/generator/assembler.factor"
        "/library/compiler/generator/templates.factor"
        "/library/compiler/generator/xt.factor"
        "/library/compiler/generator/generator.factor"

        "/library/compiler/compiler.factor"

        "/library/compiler/alien/malloc.factor"
        "/library/compiler/alien/c-types.factor"
        "/library/compiler/alien/structs.factor"
        "/library/compiler/alien/compiler.factor"
        "/library/compiler/alien/alien-invoke.factor"
        "/library/compiler/alien/alien-callback.factor"
        "/library/compiler/alien/syntax.factor"
        
        "/library/io/buffer.factor"

        "/library/cli.factor"
        
        "/library/bootstrap/init.factor"
        "/library/bootstrap/image.factor"
        
        ! This must be the last file of parsing words loaded
        "/library/syntax/parse-syntax.factor"

        "/library/ui/opengl/gl.factor"
        "/library/ui/opengl/glu.factor"
        "/library/ui/opengl/opengl-utils.factor"

        "/library/ui/freetype/freetype.factor"
        "/library/ui/freetype/freetype-gl.factor"

        "/library/ui/backend.factor"
        "/library/ui/timers.factor"
        "/library/ui/gadgets.factor"
        "/library/ui/layouts.factor"
        "/library/ui/hierarchy.factor"
        "/library/ui/gadgets/frames.factor"
        "/library/ui/world.factor"
        "/library/ui/paint.factor"
        "/library/ui/gadgets/theme.factor"
        "/library/ui/gadgets/labels.factor"
        "/library/ui/gestures.factor"
        "/library/ui/gadgets/borders.factor"
        "/library/ui/gadgets/buttons.factor"
        "/library/ui/gadgets/tiles.factor"
        "/library/ui/gadgets/line-editor.factor"
        "/library/ui/gadgets/sliders.factor"
        "/library/ui/gadgets/viewports.factor"
        "/library/ui/gadgets/scrolling.factor"
        "/library/ui/gadgets/editors.factor"
        "/library/ui/gadgets/tracks.factor"
        "/library/ui/gadgets/incremental.factor"
        "/library/ui/gadgets/paragraphs.factor"
        "/library/ui/gadgets/panes.factor"
        "/library/ui/gadgets/tabs.factor"
        "/library/ui/gadgets/outliner.factor"
        "/library/ui/ui.factor"
        "/library/ui/gadgets/presentations.factor"
        "/library/ui/tools/listener.factor"
        "/library/ui/tools/browser.factor"
        "/library/ui/tools/apropos.factor"
        "/library/ui/tools/help.factor"
        "/library/ui/tools/launchpad.factor"

        "/library/continuations.facts"
        "/library/errors.facts"
        "/library/kernel.facts"
        "/library/quotations.facts"
        "/library/threads.facts"
        "/library/words.facts"
        "/library/bootstrap/image.facts"
        "/library/collections/growable.facts"
        "/library/collections/arrays.facts"
        "/library/collections/graphs.facts"
        "/library/collections/hashtables.facts"
        "/library/collections/namespaces.facts"
        "/library/collections/queues.facts"
        "/library/collections/sbuf.facts"
        "/library/collections/sequence-combinators.facts"
        "/library/collections/sequence-sort.facts"
        "/library/collections/sequences-epilogue.facts"
        "/library/collections/sequences.facts"
        "/library/collections/slicing.facts"
        "/library/collections/strings.facts"
        "/library/collections/flatten.facts"
        "/library/collections/vectors.facts"
        "/library/collections/virtual-sequences.facts"
        "/library/compiler/alien/alien-callback.facts"
        "/library/compiler/alien/alien-invoke.facts"
        "/library/compiler/alien/aliens.facts"
        "/library/compiler/alien/c-types.facts"
        "/library/compiler/alien/malloc.facts"
        "/library/compiler/alien/structs.facts"
        "/library/compiler/alien/syntax.facts"
        "/library/compiler/generator/assembler.facts"
        "/library/compiler/inference/inference.facts"
        "/library/compiler/compiler.facts"
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
        "/library/syntax/early-parser.facts"
        "/library/syntax/parse-stream.facts"
        "/library/syntax/parser.facts"
        "/library/syntax/parse-syntax.facts"
        "/library/syntax/prettyprint.facts"
        "/library/syntax/see.facts"
        "/library/test/test.facts"
        "/library/tools/annotations.facts"
        "/library/tools/debugger.facts"
        "/library/tools/describe.facts"
        "/library/tools/inspector.facts"
        "/library/tools/listener.facts"
        "/library/tools/memory.facts"
        "/library/tools/walker.facts"

        "/doc/handbook/alien.facts"
        "/doc/handbook/changes.facts"
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
        "/doc/handbook/tools.facts"
        "/doc/handbook/tutorial.facts"
        "/doc/handbook/words.facts"
    } [ parse-resource* % ] each
    
    { "x86" "pentium4" } {
        "/library/compiler/x86/assembler.factor"
        "/library/compiler/x86/architecture.factor"
        "/library/compiler/x86/alien.factor"
        "/library/compiler/x86/intrinsics.factor"
    } if-arch
    
    { "pentium4" } {
        "/library/compiler/x86/intrinsics-sse2.factor"
    } if-arch

    { "ppc" } {
        "/library/compiler/ppc/assembler.factor"
        "/library/compiler/ppc/architecture.factor"
        "/library/compiler/ppc/intrinsics.factor"
    } if-arch

    { "amd64" } {
        "/library/compiler/x86/assembler.factor"
        "/library/compiler/x86/architecture.factor"
        "/library/compiler/amd64/architecture.factor"
        "/library/compiler/amd64/alien.factor"
        "/library/compiler/x86/intrinsics.factor"
        "/library/compiler/x86/intrinsics-sse2.factor"
        "/library/compiler/amd64/intrinsics.factor"
    } if-arch
    
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

FORGET: if-arch
FORGET: parse-resource*
