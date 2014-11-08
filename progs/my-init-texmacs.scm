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

; functions for table
(define CELL_HCENTER '(cwith "1" "-1" "1" "1" "cell-halign" "c"))

(define (get-block body)
  (cons 'block (cons body '())))

(define (do-get-tformat body)
  (cons 'tformat (cons CELL_HCENTER (cons body '()))))

(define (get-row body)
  (cons 'row (cons body '())))

(define (get-cell body)
  (cons 'cell (cons body '())))

(define (do-get-table body)
  (define result '())
  (foreach (i body)
           (set! result (cons (get-row (get-cell i)) result)))
  (cons 'table result)
  )

(define (do-get-block body)
  (get-block (do-get-tformat (do-get-table body))))

; functions for graphics
(define (do-get-graphics body) (cons 'graphics body))

(define (do-get-point x y)
  (cons 'point (cons (number->string x) (cons (number->string y) '()))))

(define (do-get-text-at body position)
  (list 'with "text-at-valign" "center" "text-at-halign" "left"
        (list 'text-at body position)))

; functions for struct graph
(define (get-width body)
  (cadr (box-info body "w")))

(define (get-height body)
  (cadr (box-info body "h")))

(define (get-self-geometry name_body)
  (define result '())
  (define table-content '())
  (define (extract-string elem)
    (if (list? elem) (cadr elem) elem))
  (define body (caddr name_body))
  (define name (cadr name_body))
  (set! table-content (cons (cadr body) table-content))
  (foreach (elem (cddr body))
           (set! table-content (cons (extract-string elem) table-content)))
  (set! table-content (reverse table-content))
  (foreach (elem (cddr body))
           (if (list? elem) (set! result (cons (get-self-geometry elem)
                                               result))
               (null? '())))
  (set! result (reverse result))
  (set! result 
        (cons (list table-content (list (get-width (do-get-block table-content)) 
                                  (get-height (do-get-block table-content))))
              result))
  (list name result))

(define (struct-graph body)
  (set! body (tree->stree body))
  (set! body (list 'tree "root" body))
  (set! body (get-self-geometry body))
  (display body))

;(inactive (extern "struct-graph" (tree "struct" "1" "2" "3")))
;(with "gr-mode" "point" "gr-frame" (tuple "scale" "1cm" (tuple "0.5gw" "0.5gh")) "gr-geometry" (tuple "geometry" "0.788016par" "0.6par" "center") (graphics "" (point "-5.42658" "3.26161") (point "-5.44616" "2.04769") (point "-2.0002" "1.14704") (point "-1.68693" "2.51759")))

; draw a rose
(define (rose r nsteps)
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
  `(with  "gr-geometry"  ,(cons 'tuple '("geometry" "0.5par" "0.5par" "center")) ,(do-get-graphics (append lines points))))

