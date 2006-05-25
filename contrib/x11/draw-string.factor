
IN: x

USING: kernel math arrays namespaces sequences x11 x rectangle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: text-width ( string -- width ) font get swap dup length XTextWidth ;

: string-size ( string -- size ) text-width font get font-height 2array ;

: string-rect ( string -- rect ) string-size { 0 0 } swap <rect> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: base-point ( rect -- )
  top-left font get XFontStruct-ascent 0 swap 2array v+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-string-top-left ( point string -- )
  dup string-rect swapd move-top-left base-point swap draw-string ;

: draw-string-top-right ( point string -- )
  dup string-rect swapd move-top-right base-point swap draw-string ;

: draw-string-bottom-left ( point string -- )
  dup string-rect swapd move-bottom-left base-point swap draw-string ;

: draw-string-bottom-right ( point string -- )
  dup string-rect swapd move-bottom-right base-point swap draw-string ;

: draw-string-middle-center ( point string -- )
  dup string-rect swapd move-middle-center base-point swap draw-string ;
