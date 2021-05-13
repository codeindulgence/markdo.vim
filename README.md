Markdown Todo List: markdo.vim
==============================

Simple markdown based task list editing.

Features
--------

- Group tasks into weeks & days
- Auto fold weeks for quick navigation
- Syntax highlighting for entry status, @mentions #tags and date/time
- Auto prefix new lines
- Super awesome searching!
- Keyboard shortcuts to toggle entries, add new weeks and much more
- Its [mine](#background-and-disclaimer) (for now)


Install
-------

Install using your favourite package manager, e.g.
[vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'codeindulgence/markdo.vim'
```


Basic Usage
-----------

Create your `TODO.md`. This file name tells the plugin it's a `markdo` file
type and activates the plugin.

Optionally add a header:

```
My Todo List
============
```

Hit `<Leader><Return>` to add the current week. It'll appear folded to begin
with. Use the default fold mappings to open/close folds:

- `zo` to open a fold
- `zc` to close a fold
- `za` to toggle a fold
- `zr` to open all folds
- `zm` to close all folds

Place the cursor at the current day with `gt`, then hit `o` to add your first
entry!

You'll notice the new line is prepended as a list item with a check box. While
still in insert mode you'll get a new item on each new line.

Once you're done adding you can toggle the check box just by hitting `<Return>`
on an entry.


Background and Disclaimer
-------------------------

I started keeping a basic task list in a markdown file and gradually settled
into specific conventions. As the file grew I started using folds on each
weekly block. Doing this manually became tedious, so I learned how to script
custom folding. Then it grew from there to the features above.

Its opinionated and optimized for my setup, and not very configurable at this
point. Also the code is pretty messy!
