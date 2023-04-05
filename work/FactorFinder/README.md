# FactorFinder

Spotlight importer for indexing Factor source files. Permits searching metadata for Factor words and files. Currently, indexes the following attributes:

```
public_factor_uses         USING:
public_factor_uses           USE:
public_factor_tuples       TUPLE:
public_factor_symbols     SYMBOL:
public_factor_definitions       :
public_factor_definitions      ::
public_factor_definitions      M:
public_factor_definitions     M::
```

Also will index the header of a file that has the format:

```
kMDItemDisplayName ! File: test.factor<br/>
kMDItemCopyright   ! Copyright (C) 2011 PolyMicro Systems<br/>
                   ! See http://factorcode.org/license.txt for BSD license.<br/>
kMDItemVersion     ! Version: 1.0<br/>
kMDItemAuthors     ! DRI: Dave Carlton<br>
kMDItemDescription ! Description: Defintions for testing Factor spotlight<br/>
```

## Installation
1. Download the *FactorSpotlight.mdimporter* binary from **Downloads**
2. Create the folder *~/Library/Spotlight* if it dows not exist
3. Place the *FactorSpotlight.mdimporter* binary into the **Spotlight*
folder
4. Open a termianl app and enter
```
mdimport -r $HOME/Library/Spotlight/FactorSpotlight.mdimporter
```
5. Verify success
```
mdimport -A|grep factor
'public_factor_definitions'		'Definitions created in Factor file'		'(null)'		'(null)'
'public_factor_uses'		'Vocabularies used by Factor file'
'(null)'		'(null)'
```
6. If you have specific folders containing Factor source files
(.factor)
```
mdimport -i path/to/folder/containing/factor
```
7. Wait for spotlight to index, check by opening spoting and looking
at index progress
8. Verify by checking one of your file.factor files
```
mdls path/to/file.factor
```
You should see references to *public_factor_definitions* and
*public_factor_uses*

9. Try finding some files containing the defintion "hex"
```
mdfind 'public_factor_definitions == "hex"'
/Volumes/Home/davec/ownCloud/Sources/factorwork/extensions/extensions.factor
/Volumes/Home/davec/ownCloud/Sources/factorwork/FactorFinder/FactorSpotlight/test.factor
/Volumes/Home/davec/ownCloud/Sources/factorwork/davec/davec.factor
/Volumes/Home/davec/ownCloud/Sources/factor/extra/toml/toml.factor
/Volumes/Home/davec/ownCloud/Sources/factor-clean/extra/toml/toml.factor
```

[Finder Demo](https://bitbucket.org/tgunr/ffactorfinder/src/master/FinderDemo.gif)

## Build
Building the Xcode project will install the binary into the
**Spotlight** folder

