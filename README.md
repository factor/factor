# Factor

Factor is a [concatenative](https://www.concatenative.org), stack-based
programming language with [high-level
features](https://concatenative.org/wiki/view/Factor/Features/The%20language)
including dynamic types, extensible syntax, macros, and garbage collection.
On a practical side, Factor has a [full-featured
library](https://docs.factorcode.org/content/article-vocab-index.html),
supports many different platforms, and has been extensively documented.

The implementation is [fully
compiled](https://concatenative.org/wiki/view/Factor/Optimizing%20compiler)
for performance, while still supporting [interactive
development](https://concatenative.org/wiki/view/Factor/Interactive%20development).
Factor applications are portable between all common platforms.  Factor can
[deploy stand-alone
applications](https://concatenative.org/wiki/view/Factor/Deployment) on all
platforms.  Full source code for the Factor project is available under a BSD
license.

## Getting Started

### Building Factor from source

If you have a build environment set up, then you can build Factor from git.
These scripts will attempt to compile the Factor binary and bootstrap from
a boot image stored on factorcode.org.

To check out Factor:

* `git clone git://factorcode.org/git/factor.git`
* `cd factor`

To build the latest complete Factor system from git, either use the
build script:

* Windows: `build.cmd`
* Unix: `./build.sh update`

or download the correct boot image for your system from
http://downloads.factorcode.org/images/master/, put it in the factor
directory and run:

* Unix: `make` and then `./factor -i=boot.unix-x86.64.image`
* Windows: `nmake /f Nmakefile x86-64` and then `factor.com -i=boot.windows-x86.64.image`

Now you should have a complete Factor system ready to run.

More information on [building factor](https://concatenative.org/wiki/view/Factor/Building%20Factor)
and [system requirements](https://concatenative.org/wiki/view/Factor/Requirements).

### To run a Factor binary:

You can download a Factor binary from the grid on [https://factorcode.org](https://factorcode.org).
The nightly builds are usually a better experience than the point releases.

* Windows: Double-click `factor.exe`, or run `.\factor.com` in a command prompt
* Mac OS X: Double-click `Factor.app` or run `open Factor.app` in a Terminal
* Unix: Run `./factor` in a shell

### Learning Factor

A tutorial is available that can be accessed from the Factor environment:

```factor
"first-program" help
```

Some other simple things you can try in the listener:

```factor
"Hello, world" print

{ 4 8 15 16 23 42 } [ 2 * ] map .

1000 [1,b] sum .

4 <iota> [
    "Happy Birthday " write
    2 = "dear NAME" "to You" ? print
] each
```

For more tips, see [Learning Factor](https://concatenative.org/wiki/view/Factor/Learning).

## Documentation

The Factor environment includes extensive reference documentation and a
short "cookbook" to help you get started. The best way to read the
documentation is in the UI; press F1 in the UI listener to open the help
browser tool. You can also [browse the documentation
online](https://docs.factorcode.org).

## Command Line Usage

Factor supports a number of command line switches:

```
Usage: factor [Factor arguments] [script] [script arguments]

Common arguments:
    -help            print this message and exit
    -i=<image>       load Factor image file <image> (default factor.image)
    -run=<vocab>     run the MAIN: entry point of <vocab>
        -run=listener    run terminal listener
        -run=ui.tools    run Factor development UI
    -e=<code>        evaluate <code>
    -no-user-init    suppress loading of .factor-rc
    -roots=<paths>   a list of path-delimited extra vocab roots

Enter
    "command-line" help
from within Factor for more information.
```

You can also write scripts that can be run from the terminal, by putting
``#!/path/to/factor`` at the top of your scripts and making them executable.

## Source Organization

The Factor source tree is organized as follows:

* `vm/` - Factor VM source code (not present in binary packages)
* `core/` - Factor core library
* `basis/` - Factor basis library, compiler, tools
* `extra/` - more libraries and applications
* `misc/` - editor modes, icons, etc
* `unmaintained/` - now at [factor-unmaintained](https://github.com/factor/factor-unmaintained)

## Community

Factor developers meet in the `#concatenative` channel on
[irc.freenode.net](http://freenode.net). Drop by if you want to discuss
anything related to Factor or language design in general.

* [Factor homepage](https://factorcode.org)
* [Concatenative languages wiki](https://concatenative.org)

Have fun!
