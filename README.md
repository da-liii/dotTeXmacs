# My TeXmacs's Configurations

## Try It
The following steps will help you try my configurations:
#### Step 0: cd to your home dir
`$ cd`
#### Step 1: backup your .TeXmacs
`$ mv .TeXmacs TeXmacs.bak`
#### Step 2: clone my repo to your home
`$ git clone git://github.com/sadhen/dotTeXmacs`
#### Step 3: try it
`$ mv dotTeXmacs .TeXmacs`

## Git plugin(has been moved to https://github.com/sadhen/tigmacs )
After installing this plugin, there will be a menu entry `Git` in the menu. The usage is quite straightforward, so all you need to do is just using the menu to git your documents.

### Windows User Only
I have made the plugin work for [mysysgit](http://msysgit.github.io/) under Windows 8. 

To try it, you have to add the `PATH_TO_MSYSGIT\bin` to the system's `PATH` environment variable. To test if you have done it, type `git --version` and hit return in cmd.

**Warning**: Please have a look at this [bug](https://savannah.gnu.org/bugs/?43765) first.

### Notice
If you do not use the newest code from SVN repository, you may fail to see the Git menu. Also, I have not tested it for MacOS.

## Graph plugin
+ rose: a rose from Henri Lesourd's [tutorial](http://texmacs.org/tmweb/documents/tutorials/TeXmacs-graphics-tutorial.pdf) of TeXmacs graphics. The code in the tutorial is outdated because of the change of the TeXmacs's Scheme serialization.

+ struct-graph: a function for translating a TeXmacs "tree" representing the relations of structs in Linux Kernel to a easy-to-read graph. Some explanation and two figures can be found in my blog [post](http://sadhen.com/2014/11/09/texmacs-graphics-struct/) in Chinese.

**Notice**:

If you use an older version, you may have to add the following code to the my-init-texmacs.scm file:

``` scheme
(define (tree->number atree)
        (string->number (tree->string atree)))
```
