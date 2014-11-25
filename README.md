# My TeXmacs's Configurations

## Try It
The following steps will help you try my configurations:
```
$ cd
# Step 1: backup your .TeXmacs
$ mv .TeXmacs TeXmacs.bak
# Step 2: clone my repo to your home
$ git clone git://github.com/sadhen/dotTeXmacs
# Step 3: try it
$ mv dotTeXmacs .TeXmacs
```

## Graph plugin
+ struct-graph: a function for translating a TeXmacs "tree" representing the relations of structs in Linux Kernel to a easy-to-read graph.

**Notice**:

If you use an older version, you may have to add the following code to the my-init-texmacs.scm file:
``` scheme
(define (tree->number atree)
        (string->number (tree->string atree)))
```

+ rose: a rose from the document of TeXmacs

## Git plugin
After installing this plugin, there will be a menu entry `Git` in the menu. The usage is quite straightforward, so all you need to do is just using the menu to git your documents.

Currently, I am working on it.

## Todo

1. Change keymap `M-[` and `M-]` to `A-[` and `A-]`
