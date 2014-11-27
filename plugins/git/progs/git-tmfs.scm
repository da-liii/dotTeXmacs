(texmacs-module (git-tmfs))

(import-from (git-utils))

(tm-define (git-show-status)
           (cursor-history-add (cursor-path)) ;; FIXME: the meaning of this line
           (revert-buffer "tmfs://git/status"))

(tm-define (git-show-log)
           (cursor-history-add (cursor-path)) ;; FIXME: the meaning of this line
           (revert-buffer "tmfs://git/log"))

(tmfs-title-handler (git name doc)
                    (cond ((== name "status") "Git Status")
                          ((== name "log") "Git Log")
                          (else "unknown")))

(tmfs-load-handler (git name)
                   (cond ((== name "status")
                          (with s (git-status)
                                ($generic
                                 ($when (not s)
                                        "Not git status available!")
                                 ($when s
                                        ($tmfs-title "Git Status")
                                        ($description-long
                                         ($describe-item "Changes to be commited:"
                                                         ($for (x s)
                                                               ($with (status file) x
                                                                      (cond ((string-starts? status "A")
                                                                             (list 'concat "new file:   " file (list 'new-line)))
                                                                            ((string-starts? status "M")
                                                                             (list 'concat "modified:   " file (list 'new-line)))
                                                                            (else "")))))
                                         ($describe-item "Changes not staged for commit:"
                                                         ($for (x s)
                                                               ($with (status file) x
                                                                      (cond ((string-ends? status "M")
                                                                             (list 'concat "modified:   " file (list 'new-line)))
                                                                            (else "")))))
                                         ($describe-item "Untracked files:"
                                                         ($for (x s)
                                                               ($with (status file) x
                                                                      (cond ((== status "??")
                                                                             (list 'concat file (list 'new-line)))
                                                                            (else ""))))))))))
                         ((== name "log")
                          (with h (git-log)
                                ($generic
                                 ($tmfs-title "Git Log")
                                 ($when (not h)
                                        "This directory is not under version control.")
                                 ($when h
                                        ($description-long
                                         ($for (x h)
                                               ($with (date by msg commit) x
                                                      ($describe-item
                                                       ($inline "Commit " commit " by " (utf8->cork by) " on " date)
                                                       (utf8->cork msg)))))))))
                         (else '())))

(tm-define (git-history name)
           (cursor-history-add (cursor-path)) ;; FIXME: the meaning of this line
           (with s (url->tmfs-string name)
                 (revert-buffer (string-append "tmfs://git_history/" s))))

(tmfs-title-handler (git_history name doc)
                    (with u (tmfs-string->url name)
                          (string-append (url->system (url-tail u)) " - History")))

(tmfs-load-handler (git_history name)
                   (with u (tmfs-string->url name)
                         (with h (buffer-log u)
                               ($generic
                                ($tmfs-title "History of "
                                             ($link (url->unix u)
                                                    ($verbatim (url->system (url-tail u)))))
                                ($when (not h)
                                       "This file is not under version control.")
                                ($when h
                                       ($description-long
                                        ($for (x h)
                                              ($with (date by msg commit) x
                                                     ($describe-item
                                                      ($inline "Commit " commit " by " by " on " date)
                                                      (utf8->cork msg))))))))))

(tmfs-format-handler (commit name)
                     (if (string-contains name "|")
                         (with u (tmfs-string->url (tmfs-cdr (string-replace name "|" "/")))
                               (url-format u))
                         (url-format (tmfs-string->url name))))

(define (string-repeat str n)
  (do ((i 1 (1+ i))
       (ret "" (string-append ret str)))
      ((> i n) ret)))

(define (get-row-from-x x maxs maxv)
  (define (get-length nr)
    (let* ((ret (/ (* nr (min maxs maxv)) maxv)))
      (if (and (> ret 0) (< ret 1)) 1
          ret)))
  `(row (cell ,(third x))
        (cell ,(number->string (+ (first x) (second x))))
        (cell (concat (with color green
                            ,(string-repeat "+"
                                            (get-length (first x))))
                      (with color red
                            ,(string-repeat "-"
                                            (get-length (second x))))))))

(tmfs-load-handler (commit name)
                   (define nr 0)
                   (define ins 0)
                   (define del 0)
                   (define maxv 0) ;; the string
                   (define maxs 0) ;; the space
                   
                   (if (string-contains name "|")
                       (git-show (string-replace name "|" ":"))
                       (with m (git-commit-message name)
                             (with p (git-commit-parent name)
                                   (with d (git-commit-diff p name)
                                         (set! ins (list-fold + 0 (map first d)))
                                         (set! del (list-fold + 0 (map second d)))
                                         (set! nr (length d))
                                         (set! maxv (list-fold max 0
                                                               (map (lambda (x)
                                                                      (+ (first x) (second x)))
                                                                    d)))
                                         (set! maxs
                                               (- 81 (list-fold max 0
                                                                (map (lambda (x)
                                                                       (+ (string-length
                                                                           (number->string (+ (first x) (second x))))
                                                                          (string-length (cork->utf8 (second (third x))))))
                                                                     d))))
                                         ($generic
                                          ($tmfs-title "Commit Message of " (string-take name 7))
                                          (if (== name p)
                                              "parent 0"
                                              `(concat "parent " ,($link (string-append "tmfs://commit/" p) p)))
                                          (list 'new-line)
                                          ($for (x m) `(concat ,(utf8->cork x) ,(list 'new-line)))
                                          "-----"
                                          (list 'new-line)
                                          `(verbatim
                                            (tabular
                                             (tformat
                                              (cwith "1" "-1" "1" "-1"
                                                     cell-lsep "0pt")
                                              ,(cons 'table
                                                     (map (lambda (x) (get-row-from-x x maxs maxv)) d)))))
                                          (list 'new-line)
                                          `(concat ,nr " files changed, "
                                                   ,ins " insertions(" (verbatim (with color green "+")) "), "
                                                   ,del " deletions(" (verbatim (with color red "-")) ")")))))))



