! Copyright (C) 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: format-using qw tools.test ;

{ "USING: ;" } [ { } format-using ] unit-test
{ "USE: vocab" } [ { "vocab" } format-using ] unit-test
{ "USING:
    io.directories io.encodings.utf8 io.files io.pathnames
    kernel
    math math.parser
    namespaces sequences sorting unicode
    xml.syntax xml.writer
;" }
[
    qw{
        kernel
        io.directories io.encodings.utf8 xml.writer io.files math
        io.pathnames namespaces math.parser sequences sorting
        unicode xml.syntax
    } format-using
] unit-test

{ "USING:
    accessors bit-arrays bit-sets interval-sets kernel literals
    math math.parser
    prettyprint.custom prettyprint.sections
    sequences sets strings typed
;" }
[
    qw{
        accessors literals kernel typed interval-sets bit-sets bit-arrays
        math math.parser prettyprint.custom prettyprint.sections sets
        strings sequences
    } format-using
] unit-test

{ "USING:
    accessors arrays assocs calendar
    combinators combinators.short-circuit
    concurrency.flags concurrency.mailboxes
    continuations destructors
    documents documents.elements
    fonts hashtables
    help help.markup help.tips
    io io.styles
    kernel lexer listener literals
    math math.vectors
    models models.arrow models.delay
    namespaces parser prettyprint sequences source-files.errors
    splitting strings system threads
    ui ui.commands ui.gadgets ui.gadgets.editors
    ui.gadgets.glass ui.gadgets.labeled ui.gadgets.panes
    ui.gadgets.scrollers ui.gadgets.status-bar
    ui.gadgets.toolbar ui.gadgets.tracks ui.gestures
    ui.operations ui.pens.solid ui.theme ui.tools.browser
    ui.tools.common ui.tools.debugger ui.tools.error-list
    ui.tools.listener.completion ui.tools.listener.history
    ui.tools.listener.popups
    vocabs vocabs.loader vocabs.parser vocabs.refresh
    words
;" }
[
    qw{
        accessors arrays assocs calendar combinators
        combinators.short-circuit concurrency.flags
        concurrency.mailboxes continuations destructors documents
        documents.elements fonts hashtables help help.markup help.tips
        io io.styles kernel lexer listener literals math math.vectors
        models models.arrow models.delay namespaces parser prettyprint
        sequences source-files.errors splitting strings system threads
        ui ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.glass
        ui.gadgets.labeled ui.gadgets.panes ui.gadgets.scrollers
        ui.gadgets.status-bar ui.gadgets.toolbar ui.gadgets.tracks
        ui.gestures ui.operations ui.pens.solid ui.theme
        ui.tools.browser ui.tools.common ui.tools.debugger
        ui.tools.error-list ui.tools.listener.completion
        ui.tools.listener.history ui.tools.listener.popups vocabs
        vocabs.loader vocabs.parser vocabs.refresh words
    } format-using
] unit-test
