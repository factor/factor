USING: windows.offscreen effects tools.test kernel images ;

{ 1 1 } [ [ [ ] make-bitmap-image ] with-memory-dc ] must-infer-as
{ t } [ [ { 10 10 } swap [ ] make-bitmap-image ] with-memory-dc image? ] unit-test
