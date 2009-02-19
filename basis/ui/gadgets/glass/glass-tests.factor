IN: ui.gadgets.glass.tests
USING: tools.test ui.gadgets.glass ui.gadgets.worlds ui.gadgets
math.rectangles namespaces accessors models ;

<gadget> "" f <model> <world>
{ 1000 1000 } >>dim
"w" set

[ ] [ <gadget> "g" set ] unit-test

[ ] [ "w" get "g" get { 0 0 } { 100 100 } <rect> show-glass ] unit-test

[ ] [ "g" get hide-glass ] unit-test

[ f ] [ "g" get parent>> ] unit-test

[ t ] [ "w" get layers>> empty? ] unit-test