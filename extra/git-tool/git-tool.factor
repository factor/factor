
USING: accessors combinators.cleave combinators.short-circuit
concurrency.combinators destructors fry io io.directories
io.encodings io.encodings.utf8 io.launcher io.pathnames
io.pipes io.ports kernel locals math namespaces sequences
splitting strings ui ui.gadgets ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.labels ui.gadgets.packs
ui.gadgets.tracks ;

IN: git-tool

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: head** ( seq obj -- seq/f ) dup number? [ head ] [ dupd find drop head ] if ;

: tail** ( seq obj -- seq/f )
  dup number?
    [ tail ]
    [ dupd find drop [ tail ] [ drop f ] if* ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: <process-stdout-stderr-reader> ( DESC -- process stream stream )
  [
    [let | STDOUT-PIPE [ (pipe) |dispose ]
           STDERR-PIPE [ (pipe) |dispose ] |

      [let | PROCESS [ DESC >process ] |

        PROCESS
          [ STDOUT-PIPE out>> or ] change-stdout
          [ STDERR-PIPE out>> or ] change-stderr
        run-detached

        STDOUT-PIPE out>> dispose
        STDERR-PIPE out>> dispose

        STDOUT-PIPE in>> <input-port> utf8 <decoder>
        STDERR-PIPE in>> <input-port> utf8 <decoder> ] ]
  ]
  with-destructors ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run-process/result ( desc -- process )
  <process-stdout-stderr-reader>
  {
    [ contents [ string-lines ] [ f ] if* ]
    [ contents [ string-lines ] [ f ] if* ]
  }
  parallel-spread
  [ >>stdout ] [ >>stderr ] bi*
  dup wait-for-process >>status ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! process popup windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: popup-window ( title contents -- )
  dup string? [ ] [ "\n" join ] if
  <editor> tuck set-editor-string swap open-window ;

: popup-process-window ( process -- )
  [ stdout>> [ "output" swap popup-window ] when* ]
  [ stderr>> [ "error"  swap popup-window ] when* ]
  [
    [ stdout>> ] [ stderr>> ] bi or not
    [ "Process" "NO OUTPUT" popup-window ]
    when
  ]
  tri ;

: popup-if-error ( process -- )
  { [ status>> 0 = not ] [ popup-process-window t ] } 1&& drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: git-process ( REPO DESC -- process )
  REPO [ DESC run-process/result ] with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-status-section ( lines section -- lines/f )
  '[ _ = ] tail**
    [
      [ "#\t" head?      ] tail**
      [ "#\t" head?  not ] head**
      [ 2 tail ] map
    ]
    [ f ]
  if* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: colon ( -- ch ) CHAR: : ;
: space ( -- ch ) 32      ;

: git-status-line-file ( line -- file )
  { [ colon = ] 1 [ space = not ] } [ tail** ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <git-status>
  repository
  to-commit-new
  to-commit-modified
  to-commit-deleted
  modified
  deleted
  untracked ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: check-empty ( seq -- seq/f ) dup empty? [ drop f ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: refresh-git-status ( STATUS -- STATUS )

  [let | LINES [ STATUS repository>> { "git" "status" } git-process stdout>> ] |

    STATUS
    
      LINES "# Changes to be committed:" git-status-section
        [ "new file:" head? ] filter
        [ git-status-line-file ] map
        check-empty
      >>to-commit-new
    
      LINES "# Changes to be committed:" git-status-section
        [ "modified:" head? ] filter
        [ git-status-line-file ] map
        check-empty
      >>to-commit-modified

      LINES "# Changes to be committed:" git-status-section
        [ "deleted:" head? ] filter
        [ git-status-line-file ] map
        check-empty
      >>to-commit-deleted

      LINES "# Changed but not updated:" git-status-section
        [ "modified:" head? ] filter
        [ git-status-line-file ] map
        check-empty
      >>modified
    
      LINES "# Changed but not updated:" git-status-section
        [ "deleted:" head? ] filter
        [ git-status-line-file ] map
        check-empty
      >>deleted

      LINES "# Untracked files:" git-status-section >>untracked ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: git-status ( REPO -- <git-status> )

  <git-status> new REPO >>repository refresh-git-status ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: factor-git-status ( -- <git-status> ) "resource:" git-status ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! git-tool
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: to-commit ( <git-status> -- seq )
  { to-commit-new>> to-commit-modified>> to-commit-deleted>> } 1arr concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: refresh-status-pile ( STATUS PILE -- )

  STATUS refresh-git-status drop

  PILE clear-gadget

  PILE

  ! Commit section

  [wlet | add-commit-path-button [| TEXT PATH |

            { 1 0 } <track>

              TEXT <label> 2/8 track-add
              PATH <label> 6/8 track-add

              "Reset"
              [
                drop
                
                STATUS repository>>
                { "git" "reset" "HEAD" PATH }
                git-process
                drop
                
                STATUS PILE refresh-status-pile
              ]
              <bevel-button> f track-add

            add-gadget ] |

    STATUS to-commit
    [
      "Changes to be committed" <label> reverse-video-theme add-gadget

      STATUS to-commit-new>>
      [| PATH | "new file: " PATH add-commit-path-button ]
      each

      STATUS to-commit-modified>>
      [| PATH | "modified: " PATH add-commit-path-button ]
      each

      STATUS to-commit-deleted>>
      [| PATH | "deleted: " PATH add-commit-path-button ]
      each

      <pile> 1 >>fill

        [let | EDITOR [ <editor> "COMMIT MESSAGE" over set-editor-string ] |

          EDITOR add-gadget
  
          "Commit"
          [
           drop
           [let | MSG [ EDITOR editor-string ] |

              STATUS repository>>
              { "git" "commit" "-m" MSG } git-process
              popup-if-error ]
           STATUS PILE refresh-status-pile
          ]
          <bevel-button>
          add-gadget ]
       
      add-gadget

    ]
    when ]

  ! Modified section

  STATUS modified>>
  [
    "Modified but not updated" <label> reverse-video-theme add-gadget

    STATUS modified>>
    [| PATH |

      <shelf>

        PATH <label> add-gadget

        "Add"
        [
          drop
          STATUS repository>> { "git" "add" PATH } git-process popup-if-error
          STATUS PILE refresh-status-pile
        ]
        <bevel-button> add-gadget

        "Diff"
        [
          drop
          STATUS repository>> { "git" "diff" PATH } git-process
          popup-process-window
        ]
        <bevel-button> add-gadget

      add-gadget
      
    ]
    each
    
  ]
  when

  ! Untracked section

  STATUS untracked>>
  [
    "Untracked files" <label> reverse-video-theme add-gadget

    STATUS untracked>>
    [| PATH |

      { 1 0 } <track>

        PATH <label> f track-add

        "Add"
        [
          drop
          STATUS repository>> { "git" "add" PATH } git-process popup-if-error
          STATUS PILE refresh-status-pile
        ]
        <bevel-button> f track-add

      add-gadget

    ]
    each
    
  ]
  when

  ! Refresh button

  "Refresh" [ drop STATUS PILE refresh-status-pile ] <bevel-button> add-gadget

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: git-remote-branches ( REPO NAME -- seq )
  REPO { "git" "remote" "show" NAME } git-process stdout>>
  "  Tracked remote branches" over index 1 + tail first " " split
  [ empty? not ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: refresh-remotes-pile ( REPO PILE -- )

  PILE clear-gadget

  PILE
  
  "Remotes" <label> reverse-video-theme add-gadget

  REPO { "git" "remote" } git-process stdout>> [ empty? not ] filter

  [| NAME |

    [let | BRANCH! [ "master" ] |
  
      { 1 0 } <track>
  
        NAME <label> 1 track-add

        [let | BRANCH-BUTTON [ "master" [ drop ] <bevel-button> ] |

          BRANCH-BUTTON
          [
            drop
                  
            <pile>
                  
              1 >>fill
    
              REPO NAME git-remote-branches
                [| OTHER-BRANCH |
                  OTHER-BRANCH
                    [
                      drop
                          
                      OTHER-BRANCH BRANCH!
                          
                      OTHER-BRANCH BRANCH-BUTTON gadget-child set-label-string
                          
                    ]
                  <bevel-button>
                  add-gadget
                ]
              each
                    
            "Select a branch" open-window
           ]
           >>quot

           1 track-add ]
  
        "Fetch"
        [ drop REPO { "git" "fetch" NAME } git-process popup-process-window ]
        <bevel-button>
        1 track-add
  
        "..remote/branch"
        [
          drop
          [let | ARG [ { ".." NAME "/" BRANCH } concat ] |
            REPO { "git" "log" ARG } git-process popup-process-window ]
        ]
        <bevel-button>
        1 track-add
  
        "Merge"
        [
          drop
          [let | ARG [ { NAME "/" BRANCH } concat ] |
            REPO { "git" "merge" ARG } git-process popup-process-window ]
        ]
        <bevel-button>
        1 track-add
  
        "remote/branch.."
        [
          drop
          [let | ARG [ { NAME "/" BRANCH ".." } concat ] |
            REPO { "git" "log" ARG } git-process popup-process-window ]
        ]
        <bevel-button>
        1 track-add
  
        "Push"
        [
          drop
          REPO { "git" "push" NAME "master" } git-process popup-process-window 
        ]
        <bevel-button>
        1 track-add

        add-gadget ]

    ]
  each

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: git-tool ( REPO -- )

  <pile> 1 >>fill

    "Repository: " REPO [ current-directory get ] with-directory append
    <label>
    add-gadget

    [let | STATUS [ REPO git-status ]
           PILE   [ <pile> 1 >>fill ] |

      [
        [
          [let | MONITOR [ REPO t <monitor> ] |
            [ MONITOR next-change 2drop STATUS PILE refresh-status-pile t ]
            loop
          ]
        ]
        with-monitors
      ]
      in-thread
           
      STATUS PILE refresh-status-pile
      
      PILE add-gadget ]

    ! REPO git-status <pile> 1 >>fill tuck refresh-status-pile  add-gadget
    REPO            <pile> 1 >>fill tuck refresh-remotes-pile add-gadget

  "Git" open-window ;


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: factor-git-tool ( -- ) "resource:" git-tool ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

