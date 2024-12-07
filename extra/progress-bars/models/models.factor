! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar fonts io io.files io.files.info kernel
math models models.arrow namespaces progress-bars threads
ui.gadgets.labels ui.gadgets.panes ;
IN: progress-bars.models

SYMBOL: progress-bar

: set-progress-bar ( ratio/float -- )
    \ progress-bar get set-model ;

: with-progress-bar ( quot -- )
    [ 0 <model> \ progress-bar ] dip with-variable ; inline

: <progress-display> ( model n -- gadget )
    [ '[ _ make-progress-bar ] <arrow> <label-control> ] keep
    [ 0 ] dip make-progress-bar >>string
    monospace-font >>font ;

SYMBOL: file-size

: update-file-progress ( -- n )
    tell-input file-size get / [ set-progress-bar ] keep ;

: file-progress-loop ( -- )
    update-file-progress 1 = [
        100 milliseconds sleep file-progress-loop
    ] unless ;

: with-file-reader-progress ( path encoding quot -- )
    '[
        _ dup file-info size>> file-size set
        _ _ [
            [ file-progress-loop ] "file-reader-progress" spawn drop
            \ progress-bar get 40 <progress-display> gadget. yield
        ] prepose
        [ update-file-progress drop ] compose
        with-file-reader
    ] with-progress-bar ; inline

: with-progress-display ( quot -- )
    '[ \ progress-bar get 50 <progress-display> gadget. @ ] with-progress-bar ; inline
