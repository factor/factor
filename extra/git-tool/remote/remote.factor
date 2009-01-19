
USING: accessors calendar git-tool git-tool io.directories
io.monitors io.pathnames kernel locals math namespaces
sequences splitting system threads ui ui.gadgets
ui.gadgets.buttons ui.gadgets.labels ui.gadgets.packs ;

USING: git-tool ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: git-tool.remote

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <git-remote-gadget> < pack
  repository
  branch
  remote
  remote-branch
  fetch-period
  push
  closed
  last-refresh ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: current-branch ( REPO -- branch )
  { "git" "branch" } git-process stdout>> [ "* " head? ] find nip 2 tail ;

: list-branches ( REPO -- branches )
  { "git" "branch" } git-process stdout>>
  [ empty? not ] filter
  [ 2 tail ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: list-remotes ( REPO -- remotes )
  { "git" "remote" } git-process stdout>> [ empty? not ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: list-remote-branches ( REPO REMOTE -- branches )
  [let | OUT [ REPO { "git" "remote" "show" REMOTE } git-process stdout>> ] |

    "  Tracked remote branches" OUT member?
      [
        OUT
        "  Tracked remote branches" OUT index 1 + tail first " " split
        [ empty? not ] filter
      ]
      [
        OUT
        OUT [ "  New remote branches" head? ] find drop
        1 + tail first " " split
        [ empty? not ] filter
      ]
    if ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: refresh-git-remote-gadget ( GADGET -- )

  [let | REPO [ GADGET repository>> ] |

    ! GADGET clear-gadget

    ! GADGET

    { }

    ! Repository label

    "Repository: " REPO [ current-directory get ] with-directory append
    <label>
    suffix

    ! Branch button
    
    <shelf>

      "Branch: " <label> add-gadget

      REPO current-branch
      [
        drop
        
        <pile>
          REPO list-branches

          [| BRANCH |

            BRANCH
            [
              drop
              REPO { "git" "checkout" BRANCH } git-process popup-if-error
              GADGET refresh-git-remote-gadget
            ]
            <bevel-button> add-gadget

          ]
          each

        "Select a branch" open-window
        
      ]
      <bevel-button> add-gadget

    suffix

    ! Remote button

    <shelf>

      "Remote: " <label> add-gadget

      GADGET remote>>
      [
        drop

        <pile>

          REPO list-remotes

          [| REMOTE |

            REMOTE
            [
              drop
              GADGET REMOTE >>remote drop
              GADGET "master" >>remote-branch drop
              GADGET refresh-git-remote-gadget
            ]
            <bevel-button> add-gadget

          ]
          each

        "Select a remote" open-window
        
      ]
      <bevel-button> add-gadget

    suffix

    ! Remote branch button

    <shelf>

      "Remote branch: " <label> add-gadget

      GADGET remote-branch>>
      [
        drop

        <pile>

          REPO GADGET remote>> list-remote-branches

          [| REMOTE-BRANCH |

            REMOTE-BRANCH
            [
              drop
              GADGET REMOTE-BRANCH >>remote-branch drop
              GADGET refresh-git-remote-gadget
            ]
            <bevel-button> add-gadget
          ]
        
          each

        "Select a remote branch" open-window

      ]
      <bevel-button> add-gadget

    suffix

    ! Fetch button

    "Fetch"
    [
      drop
      [let | REMOTE [ GADGET remote>> ] |
        REPO { "git" "fetch" REMOTE } git-process popup-if-error ]
      
      GADGET refresh-git-remote-gadget
    ]
    <bevel-button> suffix

    ! Available changes

    [let | REMOTE        [ GADGET remote>>        ]
           REMOTE-BRANCH [ GADGET remote-branch>> ] |

      [let | ARG [ { ".." REMOTE "/" REMOTE-BRANCH } concat ] |

        [let | PROCESS [ REPO { "git" "log" ARG } git-process ] |

          PROCESS stdout>>
            [
              <shelf>
              
                "Changes available:" <label> add-gadget

                "View"
                [
                  drop
                  PROCESS popup-process-window
                ]
                <bevel-button> add-gadget

                "Merge"
                [
                  drop

                  [let | ARG [ { REMOTE "/" REMOTE-BRANCH } concat ] |

                    REPO { "git" "merge" ARG } git-process popup-process-window

                  ]

                  GADGET refresh-git-remote-gadget

                ]
                <bevel-button> add-gadget

              suffix

            ]
          when

        ] ] ]


    ! Pushable changes

    [let | REMOTE        [ GADGET remote>>        ]
           REMOTE-BRANCH [ GADGET remote-branch>> ] |

      [let | ARG [ { REMOTE "/" REMOTE-BRANCH ".." } concat ] |

        [let | PROCESS [ REPO { "git" "log" ARG } git-process ] |

          PROCESS stdout>>
            [
              <shelf>
              
                "Pushable changes: " <label> add-gadget

                "View"
                [
                  drop
                  PROCESS popup-process-window
                ]
                <bevel-button> add-gadget

                "Push"
                [
                  drop

                  REPO { "git" "push" REMOTE REMOTE-BRANCH }
                  git-process
                  popup-process-window

                  GADGET refresh-git-remote-gadget

                ]
                <bevel-button> add-gadget

              suffix

            ]
          when

        ] ] ]

    GADGET clear-gadget

    GADGET swap

    [ add-gadget ] each
    
    drop

  ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-fetch-thread ( GADGET -- )

  GADGET f >>closed drop
  
  [

    [

      GADGET closed>>
        [ f ]
        [
          [let | REPO          [ GADGET repository>> ]
                 REMOTE-BRANCH [ GADGET remote-branch>> ] |
            
            REPO { "git" "fetch" REMOTE-BRANCH } git-process drop ]

          GADGET refresh-git-remote-gadget

          GADGET fetch-period>> sleep

          t
        ]
      if
      

    ]
    loop
    
  ]
  
  in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-monitor-thread ( GADGET -- )

  GADGET f >>closed drop

  [
    [
      [let | MONITOR [ GADGET repository>> t <monitor> ] |

        [
          GADGET closed>>
          [ f ]
          [
            
            [let | PATH [ MONITOR next-change drop ] |

              ".git" PATH subseq?
                [ ]
                [
                  micros
                  GADGET last-refresh>> 0 or -
                  1000000 >
                    [
                      GADGET micros >>last-refresh drop
                      GADGET refresh-git-remote-gadget
                    ]
                  when
                ]
              if ]

            t

          ]
          if
        ]
        loop
      ]
    ]
    with-monitors
  ]
  in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: <git-remote-gadget> pref-dim* ( gadget -- dim ) drop { 500 500 } ;

M:: <git-remote-gadget> graft*   ( GADGET -- )
  GADGET start-fetch-thread
  GADGET start-monitor-thread ;

M:: <git-remote-gadget> ungraft* ( GADGET -- ) GADGET t >>closed drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: git-remote-tool ( REPO -- )

  <git-remote-gadget> new-gadget
  
    { 0 1 } >>orientation
    1       >>fill

    REPO >>repository

    "origin" >>remote

    "master" >>remote-branch

    5 minutes >>fetch-period

  dup refresh-git-remote-gadget

  "git-remote-tool" open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: factor-git-remote-tool ( -- ) "resource:" git-remote-tool ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: factor-git-remote-tool