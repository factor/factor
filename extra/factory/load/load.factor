
USING: kernel io.files parser editors sequences ;

IN: factory.load

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: file-or ( file file -- file ) over exists? [ drop ] [ nip ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: personal-factory-rc ( -- path ) home "/.factory-rc" append ;

: system-factory-rc ( -- path ) "extra/factory/factory-rc" resource-path ;

: factory-rc ( -- path ) personal-factory-rc system-factory-rc file-or ;

: load-factory-rc ( -- ) factory-rc run-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: personal-factory-menus ( -- path ) home "/.factory-menus" append ;

: system-factory-menus ( -- path )
"extra/factory/factory-menus" resource-path ;

: factory-menus ( -- path )
personal-factory-menus system-factory-menus file-or ;

: load-factory-menus ( -- ) factory-menus run-file ;

: edit-factory-menus ( -- ) factory-menus 0 edit-location ;
