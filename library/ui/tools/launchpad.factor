! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: gadgets-presentations memory io gadgets-panes
gadgets-scrolling namespaces help kernel gadgets-listener
gadgets-browser gadgets-search ;

: handbook-window ( -- )
    T{ link f "handbook" } show ;

: memory-window ( -- )
    [ heap-stats. terpri room. ] make-pane <scroller>
    "Memory" open-titled-window ;

: globals-window ( -- )
    global show ;

! world {
!     { f "Listener" f [ drop listener-window ] }
!     { f "Browser" f [ drop browser-window ] }
!     { f "Apropos" f [ drop apropos-window ] }
!     { f "Help" f [ drop handbook-window ] }
!     { f "Search Help" f [ drop search-help-window ] }
!     { f "Globals" f [ drop globals-window ] }
!     { f "Memory" f [ drop memory-window ] }
!     { f "Save image" f [ drop save ] }
!     { f "Exit" f [ drop 0 exit ] }
! } define-commands
