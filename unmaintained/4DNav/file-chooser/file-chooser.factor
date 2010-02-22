! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING:
kernel
io.files
io.backend
io.directories
io.files.info
io.pathnames
sequences
models
strings
ui
ui.operations
ui.commands
ui.gestures
ui.gadgets
ui.gadgets.buttons
ui.gadgets.lists
ui.gadgets.labels
ui.gadgets.tracks
ui.gadgets.packs
ui.gadgets.panes
ui.gadgets.scrollers
prettyprint
combinators
accessors
values
tools.walker
fry
;
IN: 4DNav.file-chooser

TUPLE: file-chooser < track 
    path
    extension 
    selected-file
    presenter
    hook  
    list
    ;

: find-file-list ( gadget -- list )
    [ file-chooser? ] find-parent list>> ;

file-chooser H{
    { T{ key-down f f "UP" } 
        [ find-file-list select-previous ] }
    { T{ key-down f f "DOWN" } 
        [ find-file-list select-next ] }
    { T{ key-down f f "PAGE_UP" } 
        [ find-file-list list-page-up ] }
    { T{ key-down f f "PAGE_DOWN" } 
        [ find-file-list list-page-down ] }
    { T{ key-down f f "RET" } 
        [ find-file-list invoke-value-action ] }
    { T{ button-down } 
        request-focus }
    { T{ button-down f 1 } 
        [ find-file-list invoke-value-action ]  }
} set-gestures

: list-of-files ( file-chooser -- seq )
     [ path>> value>> directory-entries ] [ extension>> ] bi
     '[ [ name>> _ [ tail? ] with any? ] 
     [ directory? ] bi or ]  filter
;

: update-filelist-model ( file-chooser -- )
    [ list-of-files ] [ model>> ] bi set-model ;

: init-filelist-model ( file-chooser -- file-chooser )
    dup list-of-files <model> >>model ; 

: (fc-go) ( file-chooser button quot -- )
    [ [ file-chooser? ] find-parent dup path>> ] dip
    call
    normalize-path swap set-model
    update-filelist-model
    drop ; inline

: fc-go-parent ( file-chooser button -- )
    [ dup value>> parent-directory ] (fc-go) ;

: fc-go-home ( file-chooser button -- )
    [ home ] (fc-go) ;

: fc-change-directory ( file-chooser file -- )
    dupd [ path>> value>> normalize-path ] [ name>> ] bi* 
    append-path over path>> set-model    
    update-filelist-model
;

: fc-load-file ( file-chooser file -- )
  over [ name>> ] [ selected-file>> ] bi* set-model 
  [ [ path>> value>> ] [ selected-file>> value>> ] bi append ] [ hook>> ] bi
  call( path -- )
; inline

! : fc-ok-action ( file-chooser -- quot )
!  dup selected-file>> value>>  "" =
!    [ drop [ drop ] ] [    
!            [ path>> value>> ] 
!            [ selected-file>> value>> append ] 
!            [ hook>> prefix ] tri
!        [ drop ] prepend
!    ]  if ; 

: line-selected-action ( file-chooser -- )
     dup list>> list-value
     dup directory? 
     [ fc-change-directory ] [ fc-load-file ] if ;

: present-dir-element ( element -- string )
    [ name>> ] [ directory? ] bi   [ "-> " prepend ] when ;

: <file-list> ( file-chooser -- list )
  dup [ nip line-selected-action ] curry 
  [ present-dir-element ] rot model>> <list> ;

: <file-chooser> ( hook path extension -- gadget )
    { 0 1 } file-chooser new-track
    swap >>extension
    swap <model> >>path
    "" <model> >>selected-file
    swap >>hook
    init-filelist-model
    dup <file-list> >>list
    "choose a file in directory " <label> f track-add
    dup path>> <label-control> f track-add
    dup extension>> ", " join "limited to : " prepend 
        <label> f track-add
    <shelf> 
        "selected file : " <label> add-gadget
        over selected-file>> <label-control> add-gadget
    f track-add
    <shelf> 
        over [  swap fc-go-parent ] curry  "go up" 
            swap <border-button> add-gadget
        over [  swap fc-go-home ] curry  "go home" 
            swap <border-button> add-gadget
    !    over [ swap fc-ok-action ] curry "OK" 
    !    swap <bevel-button> add-gadget
    !    [ drop ]  "Cancel" swap <bevel-button> add-gadget
    f track-add
    dup list>> <scroller> 1 track-add
;

M: file-chooser pref-dim* drop { 400 200 } ;

: file-chooser-window ( -- )
    [ . ] home { "xml" "txt" }   <file-chooser> 
    "Choose a file" open-window ;

