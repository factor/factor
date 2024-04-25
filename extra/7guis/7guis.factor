! Copyright (C) 2023 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.parser models
models.arrow sequences ui ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.editors ui.gadgets.labels
ui.gadgets.packs ;
IN: 7guis

! Can use a <repeat-button>, but that is not required functionality.
WINDOW: 7guis-counter { { title "Counter" } }
    0 <model> dup [ >dec ] <arrow> <label-control> swap
    [ nip [ 1 + ] models:change-model ] curry "Count" <label>
    swap <border-button>
    2array <shelf> swap add-gadgets
    { 10 0 } >>gap 0.5 >>align { 5 5 } <border>
    >>gadgets ;
