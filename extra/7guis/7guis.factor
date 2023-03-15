! Copyright (C) 2023 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays fonts kernel math math.parser ui
ui.gadgets ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.labels ui.gadgets.packs ui.gadgets.tracks
units units.si ;
IN: 7guis

: tfont ( -- font )
  <font> default-sans-serif-font-name >>name
  18 >>size
;

:: counter-2 ( -- )
  "0" <label> tfont >>font :> lb
  [
    horizontal <track> lb 1 track-add
    "Count" <label> tfont >>font
    [ drop lb [ dec> 1 + >dec ] change-text drop ] <border-button> 
    1 track-add
    "Counter" open-window
  ] with-ui
;

:: temp-converter ( -- )
  <editor> :> dc
  <editor> :> df
  dc model>> :> dcd
  df model>> :> dfd
  dcd dfd add-connection
  dfd dcd add-connection
  [
    <shelf> 
    dc " Celsius = " <label> df " Fahrenheit" <label> 4array
    add-gadgets "TempConv" open-window
  ] with-ui 
;
