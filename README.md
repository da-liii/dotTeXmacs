# My TeXmacs's Configurations

+ struct-graph: a function for translating a TeXmacs "tree" representing the relations of structs in Linux Kernel to a easy-to-read graph.

*Notice*:

If you use an older version, you may have to add the following code to the my-init-texmacs.scm file:
``` scheme
(define (tree->number atree)
        (string->number (tree->string atree)))
```
