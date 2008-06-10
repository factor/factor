USING: io.backend kernel continuations sequences ;
IN: io.windows.privileges

HOOK: set-privilege io-backend ( name ? -- ) inline

: with-privileges ( seq quot -- )
    over [ [ t set-privilege ] each ] curry compose
    swap [ [ f set-privilege ] each ] curry [ ] cleanup ; inline
