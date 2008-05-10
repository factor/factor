
USING: kernel continuations sequences math accessors inference macros
       fry arrays.lib unix ;

IN: unix.system-call

ERROR: unix-system-call-error word args message ;

MACRO: unix-system-call ( quot -- )
  [ ] [ infer in>> ] [ first ] tri
 '[
    [ @ dup 0 < [ dup throw ] [ ] if ]
    [ drop , narray , swap err_no strerror unix-system-call-error ]
    recover
  ] ;
