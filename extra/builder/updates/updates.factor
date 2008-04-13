
USING: kernel io.launcher bootstrap.image bootstrap.image.download
       builder.util builder.common ;

IN: builder.updates

: git-pull-cmd ( -- cmd )
  {
    "git"
    "pull"
    "--no-summary"
    "git://factorcode.org/git/factor.git"
    "master"
  } ;

: updates-available? ( -- ? )
  git-id
  git-pull-cmd try-process
  git-id
  = not ;

: new-image-available? ( -- ? )
  my-boot-image-name need-new-image?
    [ download-my-image t ]
    [ f ]
  if ;

: new-code-available? ( -- ? )
  updates-available?
  new-image-available?
  or ;