! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: models models.search namespaces tools.test
ui.gadgets.panes ui.gadgets.worlds ui.tools.button-list ;
IN: models.search.tests

{ } [
    world-buttons <model> "Active Buttons"
        <active-buttons-popup> gadget.
] unit-test

