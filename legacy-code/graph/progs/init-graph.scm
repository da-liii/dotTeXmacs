; basic functions and macros
(define-macro (foreach i . b)
  `(for-each (lambda (,(car i))
               ,(cons 'begin b))
             ,(cadr i)))

(define-macro (foreach-number i . b)
  `(do ((,(car i) ,(cadr i)
         (,(if (memq (caddr i) '(> >=)) '- '+) ,(car i) 1)))
       ((,(if (eq? (caddr i) '>)
              '<=
              (if (eq? (caddr i) '<)
                  '>=
                  (if (eq? (caddr i) '>=) '< '>)))
         ,(car i) ,(cadddr i))
        ,(car i))
     ,(cons 'begin b)))

(define (list-max nrlist)
  (if (null? nrlist) '() (eval (cons 'max nrlist))))

(define (list-sum nrlist)
  (if (null? nrlist) '() (eval (cons '+ nrlist))))

; functions for table
(define CELL_HCENTER
  '(cwith "1" "-1" "1" "1" "cell-halign" "c"))
(define TABLE_HEAD_COLOR
  '(cwith "1" "1" "1" "1" "cell-background" "yellow"))

(define (get-block body)
  (cons 'block (cons body '())))

(define (do-get-tformat body)
  (list 'tformat CELL_HCENTER TABLE_HEAD_COLOR body))

(define (get-row body)
  (cons 'row (cons body '())))

(define (get-cell body)
  (cons 'cell (cons body '())))

(define (do-get-table body)
  (define result '())
  (foreach (i body)
           (set! result (cons (get-row (get-cell i)) result)))
  (set! result (reverse result))
  (cons 'table result))

(define (do-get-block body)
  (get-block (do-get-tformat (do-get-table body))))

; functions for graphics
(define (do-get-graphics body) (cons 'graphics body))

(define (do-get-point x y)
  (cons 'point (cons (number->string x) (cons (number->string y) '()))))

(define (do-get-x point)
  (string->number (list-ref point 1)))

(define (do-get-y point)
  (string->number (list-ref point 2)))

; in TeXmacs when you look into the source, > appears the same as <gtr>
; but in the exported TeXmacs Scheme source file, they are different
(define (do-get-line point1 point2)
  (list 'with "arrow-end" "|<gtr>"
        (list 'line 
              point1
              (do-get-point (/ (+ (do-get-x point1) (do-get-x point2)) 2.0)
                            (do-get-y point1))
              (do-get-point (/ (+ (do-get-x point1) (do-get-x point2)) 2.0)
                            (do-get-y point2))
              point2)))

(define (do-get-text-at body position)
  (list 'with "text-at-valign" "center" "text-at-halign" "left"
        (list 'text-at body position)))

; functions for struct graph
(define (get-width body)
  (cadr (box-info body "w")))

(define (get-height body)
  (cadr (box-info body "h")))

(define (get-geometry body)
  (list (get-width body) (get-height body)))

(define (extract-width elem)
  (string->number (car (caddr (car (cadr elem))))))

(define (extract-height elem)
  (string->number (cadr (caddr (car (cadr elem))))))

(define (extract-self-width elem)
  (string->number (car (cadr (car (cadr elem))))))

(define (extract-self-height elem)
  (string->number (cadr (cadr (car (cadr elem))))))

(define (extract-string elem)
  (if (list? elem) (cadr elem) elem))

(define (tmlen->graph num)
  (/ num 60550.0))

(define (tmlen->gh num)
  (/ num 599040.0))

(define (tmlen->gw num)
  (/ num 998400.0))

(define (tmlen->par num)
  (/ num 998400.0))

(define (tmlen->cm num)
  (/ num 60472.4))

(define (cm->tmlen num)
  (* num 60472.4))

(define (cm->string num)
  (string-append (number->string num) "cm"))

(define (ln->tmlen num)
  (/ num 1066))

(define HGAP 80000)
(define VGAP 50000)
(define HPADDING 0.1)
(define VPADDING 0.1)

(define (get-self-and-group-geometry name-body)
  (define flag #t)
  (define result '())
  (define table-content '())
  (define body (caddr name-body))
  (define name (cadr name-body))
  (define the-block '())
  ; calculate flag
  (foreach (elem (cddr body))
           (if (list? elem) (set! flag #f) (null? '())))
  ; calculate table content
  (set! table-content (cons (cadr body) table-content))
  (foreach (elem (cddr body))
           (set! table-content (cons (extract-string elem) table-content)))
  (set! table-content (reverse table-content))
  (set! the-block (do-get-block table-content))
  ; calculate result
  (foreach (elem (cddr body))
           (if (list? elem)
               (set! result (cons (get-self-and-group-geometry elem)
                                  result))
               (null? '())))
  (set! result (reverse result))
  ; calculate the self geometry and group geometry
  (if flag (set! result (cons 
                         (list table-content 
                               (get-geometry the-block) 
                               (get-geometry the-block))
                         result))
      (set! result
            (cons (list table-content
                        (get-geometry the-block)
                        (list (number->string 
                               (+ (string->number (get-width the-block))
                                  HGAP
                                  (list-max (map extract-width result)))) 
                              (number->string 
                               (max (string->number 
                                     (get-height the-block))
                                    (+ (list-sum (map extract-height result)) 
                                       (* VGAP (- (length result) 1))))))) 
                  result)))
  (list name result))

; get the position of the struct body
(define (get-position body left bottom top)
  (define result '())
  (define new-left (+ left (extract-self-width body) HGAP))
  (define new-vgap 0)
  (define sub-body '())
  (define height-list '())
  (define tmp-v '())
  ;; input:  (h1 h2 h3) base gap
  ;; output: (base X+h1) (base+h1+gap X+h2) (base+h1+gap+h2+gap X+h3)
  (define (get-tmp-v alist base gap)
    (define result '())
    (set! alist (reverse alist))
    (set! result (cons (list base (+ base (car alist))) result))
    (foreach-number (i 1 < (length alist))
                    (set! result (rcons result
                                        `(,(+ gap (last (last result))) 
                                          ,(+ gap (list-ref alist i) 
                                              (last (last result)))))))
    (reverse result))
  
  (set! sub-body (cdr (cadr body)))
  (set! height-list (map extract-height sub-body)) ;; edited
  
  ;; calculate the new vertical gap
  (if (< (length height-list) 2) (null? '())
      (set! new-vgap
            (/ (- top (+ (list-sum height-list) bottom))
               (- (length sub-body) 1))))

  (if (= (length height-list) 1) (set! tmp-v (list (list bottom top)))
      (null? '()))
  (if (< (length height-list) 2) (null? '())
      (set! tmp-v (get-tmp-v height-list bottom new-vgap)))
  
  (if (null? height-list) (null? '())
      (foreach-number (i 0 < (length height-list))
                      (set! result 
                            (cons (get-position (list-ref sub-body i) 
                                           new-left 
                                           (car (list-ref tmp-v i)) 
                                           (cadr (list-ref tmp-v i))) 
                             result))))
  (set! result (reverse result))
  (set! result (cons (rcons (car (cadr body))
                      (list left (/ (+ bottom top) 2.0))) 
                     result))
  (list (car body) result))

(define (do-get-struct-tables body)
  (define result '())
  (define table-content '())
  (define point (list-ref (car (cadr body)) 3))

  (set! table-content (car (car (cadr body))))  
  (foreach (elem (cdr (cadr body)))
           (set! result (append (do-get-struct-tables elem) result)))
  (cons (do-get-text-at 
         (do-get-block table-content) 
         (do-get-point (tmlen->graph (car point)) (tmlen->graph (cadr point)))) 
        result))

; sx = x, sy = y + (height/2)*(1 - 1/(length content))
(define (do-get-struct-position body)
  (define content (car body))
  (define x (car (last body)))
  (define y (cadr (last body)))
  (define height (string->number (cadr (cadr body))))
  (do-get-point (tmlen->graph x) 
                (tmlen->graph (+ y (* (/ height 2.0)
                              (- 1 (/ 1 (length content))))))))

; sx = x + width
; sy = y + height/2 - (height / (length content)) * ((list-ref)+ 1/2) 
(define (list-rref elem alist)
  (cond ((null? alist) '())
        (else (cond ((eq? elem (car alist)) 0)
                    (else (+ 1 (list-rref elem (cdr alist))))))))

(define (do-get-member-position elem body)
  (define content (car body))
  (define x (car (last body)))
  (define y (cadr (last body)))
  (define height (string->number (cadr (cadr body))))
  (define width (string->number (car (cadr body))))
  (do-get-point (tmlen->graph (+ x width))
                (tmlen->graph (- (+ y (/ height 2.0))
                                 (* (/ height (length content)) 
                                    (+ (list-rref elem content) (/ 1 2)))))))

(define (do-get-lines body)
  (define result '())
  (define sub-body (cdr body))
  (define name-body (car body))
  (foreach (elem sub-body)
           (set! result (append result
                                (do-get-lines (cadr elem)))))
  (foreach (elem sub-body)
           (set! result (cons (do-get-line (do-get-member-position
                                         (car elem) name-body) 
                                        (do-get-struct-position 
                                         (car (cadr elem)))) 
                              result)))
  result)

(tm-define (do-struct-graph body)
  (:secure #t)
  (define result '())
  (define canvas-width 0)
  (define canvas-height 0)
  (set! body (list 'tree "root" body))
  (set! body (get-self-and-group-geometry body))
  (set! canvas-width (+ (extract-width body) (cm->tmlen (* 2 HPADDING))))
  (set! canvas-height (extract-height body))
  (set! body (get-position body 0 0 canvas-height))
  (set! canvas-height (+ canvas-height (cm->tmlen (* 2 VPADDING))))
  (display* body "\n")
  (set! result (do-get-struct-tables body))
  (set! result (append result (do-get-lines (cadr body))))
  (set! result (list 'with "gr-mode" "point"
                     "gr-frame" 
                     (list 'tuple "scale" "1cm" 
                             (list 'tuple (cm->string HPADDING)
                                   (cm->string VPADDING)))
                     "gr-geometry"
                     (list 'tuple "geometry" 
                           (cm->string (tmlen->cm canvas-width)) 
                           (cm->string (tmlen->cm canvas-height)) "center")
                     (do-get-graphics result)))
  result)

(tm-define (struct-graph body)
  (:secure #t)
  (set! body (tree->stree body))
  (do-struct-graph body))

(define (get-list stree)
  (define result '())
  (cond ((list? stree) 
         (foreach (elem stree)
                  (set! result (cons (get-list elem) result)))
         (set! result (cons 'list (reverse result))))
        (else (set! result stree)))
  result)

(tm-define (edit-struct-graph)
  (:secure #t)
  (define code '())
  (with t (focus-tree)
            (set! code (list 'do-struct-graph
                             (get-list (cadr (tree->stree t)))))
            (tree-set! t (eval code))))

(kbd-map ("M-e" (edit-struct-graph)))

; draw a rose
(tm-define (rose r nsteps)
  (:secure #t)
  (define pi (acos -1))
  (define points '())
  (define lines '())
  (set! r (tree->number r))
  (set! nsteps (tree->number nsteps))
  (foreach-number (i 0 < nsteps)
                  (with t (/ (* 2 i pi) nsteps)
                        (set! points
                              (cons (do-get-point (* r (cos t)) 
                                                  (* r (sin t)))
                                    points))))
  (foreach (p1 points)
           (foreach (p2 points)
                    (set! lines (cons `(line ,p1 ,p2) lines))))
  `(with  "gr-geometry"
     ,(cons 'tuple
            '("geometry" "0.5par" "0.5par" "center"))
     ,(do-get-graphics (append lines points))))
