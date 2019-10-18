USING: errors kernel quotations sequences ;
IN: mmap

! mmap interface
DEFER: mmap-r/w
DEFER: mmap-close

: with-mmap ( path quot -- )
    #! quot: ( alien -- )
    >r mmap-r/w r>
    1quotation [ keep ] append
    [ mmap-close ] cleanup ; inline

