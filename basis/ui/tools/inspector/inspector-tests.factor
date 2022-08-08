USING: kernel math models tools.test ui.tools.inspector ;

{ } [ \ + <model> <inspector-gadget> com-edit-slot ] unit-test

! Make sure we can click around in the inspector; map-index regression
{ } [ "abcdefg" make-slot-descriptions drop ] unit-test
