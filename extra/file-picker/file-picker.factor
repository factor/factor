USING: accessors sequences system vocabs ;
IN: file-picker

HOOK: open-file-dialog os ( -- paths )
HOOK: save-file-dialog os ( path -- paths )

os name>> "file-picker." prepend require
