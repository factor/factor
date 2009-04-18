IN: ui.gadgets.paragraphs.tests
USING: ui.gadgets.paragraphs ui.gadgets.paragraphs.private
ui.gadgets ui.gadgets.debug accessors tools.test namespaces
sequences kernel ;

TUPLE: fake-break < gadget ;

: <fake-break> ( -- gadget ) fake-break new { 5 5 } >>dim ;

INSTANCE: fake-break word-break

100 <paragraph>
<gadget> { 40 30 } >>dim dup "a" set add-gadget
<fake-break> add-gadget
<gadget> { 40 15 } >>dim dup "b" set add-gadget
<fake-break> add-gadget
<gadget> { 50 20 } >>dim dup "c" set add-gadget
"p" set

[ { 4 1 } ] [ "p" get wrap-paragraph [ words>> length ] map ] unit-test

[ { 85 50 } ] [ "p" get pref-dim ] unit-test

[ ] [ "p" get prefer ] unit-test

[ ] [ "p" get layout ] unit-test

[ { 0 0 } ] [ "a" get loc>> ] unit-test

[ { 45 7 } ] [ "b" get loc>> ] unit-test

[ { 0 30 } ] [ "c" get loc>> ] unit-test

100 <paragraph>
15 15 { 40 30 } <baseline-gadget> dup "a" set add-gadget
<fake-break> add-gadget
10 10 { 40 30 } <baseline-gadget> dup "b" set add-gadget
<fake-break> add-gadget
20 20 { 40 30 } <baseline-gadget> dup "c" set add-gadget
"p" set

[ { 85 65 } ] [ "p" get pref-dim ] unit-test

[ ] [ "p" get prefer ] unit-test

[ ] [ "p" get layout ] unit-test

[ { 0 0 } ] [ "a" get loc>> ] unit-test

[ { 45 5 } ] [ "b" get loc>> ] unit-test

[ { 0 35 } ] [ "c" get loc>> ] unit-test