USE: kernel

PROVIDE: core/io/windows
{ +files+ {
    { "nt/load.factor" [ winnt? ] }
    { "ce/load.factor" [ wince? ] }
} } ;
