# TeXmacs's Configurations

The Graph plugin has been moved to `legacy-code`. And I am reorganizing my configurations using Literate Programming in TeXmacs.

## Graph plugin
+ rose: a rose from Henri Lesourd's [tutorial](http://texmacs.org/tmweb/documents/tutorials/TeXmacs-graphics-tutorial.pdf) of TeXmacs graphics. The code in the tutorial is outdated because of the change of the TeXmacs's Scheme serialization.

+ struct-graph: a function for translating a TeXmacs "tree" representing the relations of structs in Linux Kernel to a easy-to-read graph. Some explanation and two figures can be found in my blog [post](http://sadhen.com/blog/2014/11/09/texmacs-graphics-struct.html) in Chinese.

**Notice**:

If you use an older version, you may have to add the following code to the my-init-texmacs.scm file:

``` scheme
(define (tree->number atree)
        (string->number (tree->string atree)))
```
