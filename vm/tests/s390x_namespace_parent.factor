USING: accessors io io.launcher kernel math ;
IN: s390x.recovery.private.parent
{ "./factor" "-no-user-init" "-no-monitors" "-q"
  "-e=USING: parser ; \"resource:vm/tests/s390x_namespace_child.factor\" run-file" }
run-process status>> 0 = [ "PRIVATE-PARENT-DEFAULT-CHILD-PASS" print flush ] [ "private child failed" throw ] if
