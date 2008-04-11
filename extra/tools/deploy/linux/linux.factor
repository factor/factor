USING: io io.files io.backend kernel namespaces sequences
system tools.deploy.backend tools.deploy.config assocs
hashtables prettyprint ;
IN: tools.deploy.linux

: copy-vm ( executable bundle-name -- vm )
  prepend-path "" append
  vm over copy-file ;
  
: copy-fonts ( name -- )  
  "fonts/" resource-path swap copy-tree-into ;
  
: create-app-dir ( vocab bundle-name -- vm )  
  dup copy-fonts
  copy-vm ;
  
: image-name ( vocab bundle-name -- str )  
  prepend-path ".image" append ;
  
: bundle-name ( -- str )  
  deploy-name get ;

M: linux deploy* ( vocab -- )
   "." resource-path [
       dup deploy-config [
           [ bundle-name create-app-dir ] keep
           [ bundle-name image-name ] keep
           namespace make-deploy-image
           bundle-name normalize-path [ "Binary deployed to " % % "." % ] "" make write
     ] bind
   ] with-directory ;  