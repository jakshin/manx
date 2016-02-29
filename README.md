![A Manx cat says: RTFM, yo](Manx_RTFM.jpg)

## Introduction

OS X's man pages are very handy, but it's not always as easy as it could be to access the information in them using the default viewer, especially in longer man pages such as bash's. Programs such as [Dash](https://kapeli.com/dash) make reading man pages much more convenient, but aren't free.

Fortunately, software bundled with OS X makes it possible to view them as PDFs, and in your favorite GUI text editor. If you have the **man2html** program installed (it's available from [MacPorts](http://www.macports.org)), you can even view them in your browser. And now **Manx** exists to make it as convenient as possible to do so.

## Usage

Once **Manx** is installed, you can use it by typing `manx` at a command prompt instead of `man`. You can optionally tell it how you'd like to view a man page.

For example, to view Manx's own man page in your default GUI text editor (whichever app opens .txt files when you double-click them), type either of these:

```bash
manx --editor manx
manx -e manx
```

If you would like to view man pages a certain way by default, you can set the MANX_OPTS environment variable to contain a command-line option, which will be applied before any options on the actual command line.

For instance, if you like viewing man pages as PDFs in Preview, you can put the following in your .bashrc and/or .zshrc:

```bash
export MANX_OPTS='--preview'
```

Then, you can just use `manx foo` at a command line to open foo's man page in Preview. Because the actual command line is parsed after MANX_OPTS, `manx -e foo` will still open foo's man page in your text editor.

## Installation

To install using the provided script, `install-manx.sh`, run the following in Terminal (paste as a single line):

```bash
curl -fsSL https://raw.githubusercontent.com/jakshin/manx/master/install-manx.sh -o install-manx.sh && chmod 755 install-manx.sh && ./install-manx.sh && rm -i install-manx.sh
```

That will install two files in their default locations, `/usr/local/bin/manx` (the executable) and `/usr/local/share/man/man1/manx.1` (the man page).

If you prefer to install to a different location, pass the desired location of `manx` to `install-manx.sh`; the man page will be installed into the appropriate parallel directory. For instance, to install to `/utils/bin/manx` and `/utils/share/man/man1/manx.1`, run the following:

```bash
curl -fsSL https://raw.githubusercontent.com/jakshin/manx/master/install-manx.sh -o install-manx.sh && chmod 755 install-manx.sh && ./install-manx.sh /utils/bin && rm -i install-manx.sh
```

## Uninstallation

To uninstall using the provided script, `uninstall-manx.sh`, run the following in Terminal (paste as a single line):

```bash
curl -fsSL https://raw.githubusercontent.com/jakshin/manx/master/uninstall-manx.sh -o uninstall-manx.sh && chmod 755 uninstall-manx.sh && ./uninstall-manx.sh && rm -i uninstall-manx.sh
```

That will attempt to find `manx` in your PATH and remove it, then uninstall manx's man page from either (a) the parallel man-page directory, or (b) wherever `man --path` reports that it can be found.

If you have installed Manx into a directory which isn't in the path, the uninstaller won't be able to find it unless you pass the directory to it, like so:

```bash
curl -fsSL https://raw.githubusercontent.com/jakshin/manx/master/uninstall-manx.sh -o uninstall-manx.sh && chmod 755 uninstall-manx.sh && ./uninstall-manx.sh /utils/bin && rm -i uninstall-manx.sh
```
