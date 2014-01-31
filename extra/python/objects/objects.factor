USING: alien.c-types alien.data kernel python.errors python.ffi ;
IN: python.objects

! Objects
: getattr ( obj str -- value )
    PyObject_GetAttrString check-new-ref ;

: setattr ( obj str value -- )
    PyObject_SetAttrString check-zero ;

: call-object ( obj args -- value )
    PyObject_CallObject check-new-ref ;

: call-object-full ( obj args kwargs -- value )
    PyObject_Call check-new-ref ;

! Tuples
: <py-tuple> ( length -- tuple )
    PyTuple_New check-new-ref ;

: py-tuple-set-item ( obj pos val -- )
    unsteal-ref PyTuple_SetItem check-zero ;

: py-tuple-get-item ( obj pos -- val )
    PyTuple_GetItem dup Py_IncRef check-new-ref ;

: py-tuple-size ( obj -- len )
    PyTuple_Size ;

: <1py-tuple> ( alien -- tuple )
    1 <py-tuple> [ 0 rot py-tuple-set-item ] keep ;

! Dicts
: <py-dict> ( -- dict )
    PyDict_New check-new-ref ;

: py-dict-set-item ( obj key val -- )
    PyDict_SetItem check-zero ;

: py-dict-set-item-string ( dict key val -- )
    PyDict_SetItemString check-zero ;

: py-dict-get-item-string ( obj key -- val )
    PyDict_GetItemString check-borrowed-ref ;

: py-dict-size ( obj -- len )
    PyDict_Size ;

! Lists
: <py-list> ( length -- list )
    PyList_New check-new-ref ;

: py-list-size ( list -- len )
    PyList_Size ;

: py-list-get-item ( obj pos -- val )
    PyList_GetItem check-borrowed-ref ;

: py-list-set-item ( obj pos val -- )
    unsteal-ref PyList_SetItem check-zero ;
