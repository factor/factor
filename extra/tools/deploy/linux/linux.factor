! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.backend kernel namespaces sequences system tools.deploy.backend
tools.deploy.config assocs hashtables prettyprint ;
IN: tools.deploy.linux
  
: create-app-dir ( vocab bundle-name -- vm )  
  dup "" copy-fonts
  "" copy-vm ;
  
: bundle-name ( -- str )  
  deploy-name get ;

M: linux deploy* ( vocab -- )
   "." resource-path [
       dup deploy-config [
           [ bundle-name create-app-dir ] keep
           [ bundle-name image-name ] keep
           namespace make-deploy-image
           bundle-name normalize-path [ "Binary deployed to " % % "." % ] "" make print
     ] bind
   ] with-directory ;  