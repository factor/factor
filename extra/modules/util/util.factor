USING: generalizations kernel namespaces sequences serialize ;
IN: modules.util
: deserialize-args ( -- ) deserialize dup length firstn ; inline
: change-global ( var quot -- ) [ [ get-global ] keep ] dip dip set-global ; inline