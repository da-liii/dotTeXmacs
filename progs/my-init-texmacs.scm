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

(define (list-max number_list)
  (cond ((null? number_list) '())
        (else 
          (cond ((eq? (length number_list) 1) (car number_list))
                (else 
                  (max (car number_list) 
                       (list-max (cdr number_list))))))))

(define (list-sum number_list)
  (cond ((null? number_list) '())
        (else
          (cond ((eq? (length number_list) 1) (car number_list))
                (else
                  (+ (car number_list)
                     (list-sum (cdr number_list))))))))

(define (snoc elem alist)
  (reverse (cons elem (reverse alist))))

(define (rac alist)
  (car (reverse alist)))
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
  (set! result (reverse result))
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

(define HGAP 100000)
(define VGAP 50000)

(define (get-self-and-group-geometry name_body)
  (define flag #t)
  (define result '())
  (define table-content '())
  (define body (caddr name_body))
  (define name (cadr name_body))
  (define the_block '())
  ; calculate flag
  (foreach (elem (cddr body))
           (if (list? elem) (set! flag #f) (null? '())))
  ; calculate table content
  (set! table-content (cons (cadr body) table-content))
  (foreach (elem (cddr body))
           (set! table-content (cons (extract-string elem) table-content)))
  (set! table-content (reverse table-content))
  (set! the_block (do-get-block table-content))
  ; calculate result
  (foreach (elem (cddr body))
           (if (list? elem) (set! result (cons (get-self-geometry elem)
                                               result))
               (null? '())))
  (set! result (reverse result))
  ; calculate the self geometry and group geometry
  (if flag (set! result (cons 
                         (list table-content 
                               (get-geometry the_block) 
                               (get-geometry the_block))
                         result))
      (set! result (cons (list table-content
                               (get-geometry the_block)
                               (list (number->string 
                                      (+ (string->number (get-width the_block))
                                        HGAP
                                        (list-max (map extract-width result)))) 
                                     (number->string 
                                      (max (string->number 
                                            (get-height the_block))
                                        (+ (list-sum (map extract-height result)) 
                                           (* VGAP (- (length result) 1))))))) 
                         result)))
  (list name result))

(define (get-position body left bottom top)
  (define result '())
  (define new_left (+ left (extract-self-width body) HGAP))
  (define new_vgap 0)
  (define sub_body '())
  (define height-list '())
  (define tmp_v '())
  (define (get-tmp-v alist base gap)
    (define result '())
    (set! alist (reverse alist))
    (set! result (cons (list base (+ base (car alist))) result))
    (foreach-number (i 1 < (length alist))
             (set! result (snoc `(,(+ gap (rac (rac result))) 
                                  ,(+ gap (list-ref alist i) 
                                      (rac (rac result))))
                                result)))
    (reverse result))
  (set! sub_body (cdr (cadr body)))
  (set! height-list (map extract-self-height sub_body))
  (if (< (length height-list) 2) (null? '())
      (set! new_vgap (/ (- top (list-sum height-list)) (- (length sub_body) 1))))
  (if (= (length height-list) 1) (set! tmp_v (list (list bottom top)))
      (null? '()))
  (if (< (length height-list) 2) (null? '())
      (set! tmp_v (get-tmp-v height-list bottom new_vgap)))
  (if (null? height-list) (null? '())
      (foreach-number (i 0 < (length height-list))
                      (set! result 
                            (cons (get-position (list-ref sub_body i) 
                                           new_left 
                                           (car (list-ref tmp_v i)) 
                                           (cadr (list-ref tmp_v i))) 
                             result))))
  (set! result (reverse result))
  (set! result (cons (snoc 
                      (list left (/ (+ bottom top) 2.0)) 
                      (car (cadr body))) 
                     result))
  (list (car body) result)
  )

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

(define (struct-graph body)
  (define result '())
  (define canvas_width 0)
  (define canvas_height 0)
  (set! body (tree->stree body))
  (set! body (list 'tree "root" body))
  (set! body (get-self-and-group-geometry body))
  (set! canvas_width (extract-width body))
  (set! canvas_height (extract-height body))
  (set! body (get-position body 0 0 canvas_height))
  (set! result (do-get-struct-tables body))
  (display (do-get-graphics result))
  (do-get-graphics result))

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

