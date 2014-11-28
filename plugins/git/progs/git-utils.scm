(texmacs-module (git-utils))

(define gitroot "invalid")

(define callgit
  "git")

(tm-define (buffer-status name)
           (let* ((name-s (url->string name))
                  (cmd (string-append callgit " status --porcelain " name-s))
                  (ret (eval-system cmd)))
             (cond ((>= (string-length ret) 2) (string-take ret 2))
                   ((file-exists? name-s) "  ")
                   (else ""))))

(tm-define (buffer-to-unadd? name)
           (with ret (buffer-status name)
                 (or (== ret "A ")
                     (== ret "M ")
                     (== ret "MM")
                     (== ret "AM")))) 

(tm-define (buffer-to-add? name)
           (with ret (buffer-status name)
                 (or (== ret "??")
                     (== ret " M")
                     (== ret "MM")
                     (== ret "AM"))))

(tm-define (buffer-histed? name)
           (with ret (buffer-status name)
                 (or (== ret "M ")
                     (== ret "MM")
                     (== ret " M")
                     (== ret "  "))))

(tm-define (buffer-tmfs? name)
           (string-starts? (url->string name)
                           "tmfs"))

(tm-define (git-add name)
           (let* ((name-s (url->string name))
                  (cmd (string-append callgit " add " name-s))
                  (ret (eval-system cmd)))
             (set-message cmd "The file is added")))

(tm-define (git-unadd name)
           (display name)
           (let* ((name-s (url->string name))
                  (cmd (string-append callgit " reset HEAD " name-s))
                  (ret (eval-system cmd)))
             (set-message cmd "The file is unadded.")
             (display cmd)))

(tm-define (git-status)
           (let* ((cmd (string-append callgit " status --porcelain"))
                  (ret1 (eval-system cmd))
                  (ret2 (string-split ret1 #\nl)))
             (define (convert name)
               (let* ((status (string-take name 2))
                      (filename (string-drop name 3))
                      (file (if (or (string-starts? status "A")
                                    (string-starts? status "?"))
                                filename
                                ($link (string-append "tmfs://git_history/file"
                                                      gitroot "/" filename)
                                       (utf8->cork filename)))))
                 (list status file)))
             (and (> (length ret2) 0)
                  (== (cAr ret2) "")
                  (map convert (cDr ret2)))))

(tm-define (git-commit-message hash)
           (let* ((cmd (string-append callgit " log -1 " hash))
                  (ret (eval-system cmd)))
             (string-split ret #\nl)))

(tm-define (git-commit-parent hash)
           (let* ((cmd (string-append callgit " log -2 --pretty=%H " hash " | tail -1"))
                  (ret (eval-system cmd)))
             (string-drop-right ret 1)))

(tm-define (git-commit-master)
           (let* ((cmd (string-append callgit " log -1 --pretty=%H"))
                  (ret (eval-system cmd)))
             (string-drop-right ret 1)))

(tm-define (git-commit-diff parent hash)
           (let* ((cmd (if (== parent hash)
                           (string-append callgit " show " hash
                                          " --numstat --pretty=oneline | tail -n +2")
                           (string-append callgit " diff --numstat " parent " " hash)))
                  (ret (eval-system cmd))
                  (ret2 (string-split ret #\nl)))
             (define (convert body)
               (let* ((alist (string-split body #\ht)))
                 (if (== (first alist) "-")
                     (list 0 0 (utf8->cork (third alist))
                           (string-length (third alist)))
                     (list (string->number (first alist))
                       (string->number (second alist))
                       ($link (string-append "tmfs://commit/"
                                             hash "|" (third alist))
                              (utf8->cork (third alist)))
                       (string-length (third alist))))))
             (and (> (length ret2) 0)
                  (== (cAr ret2) "")
                  (map convert (cDr ret2)))))

(tm-define (git-commit message)
           (let* ((cmd (string-append callgit " commit -m \"" message "\""))
                  (ret (eval-system cmd)))
             ;; (display ret)
             (set-message (string-append callgit " commit") message))
           (git-show-status))

(tm-define (git-show path)
           (let* ((cmd (string-append callgit " show " path))
                  (ret (eval-system cmd)))
             ;; (display* "\n" cmd "\n" ret "\n")
             ret))

(tm-define (string->commit str name)
           (if (== str "") '()
               (let* ((list1 (string-split str #\|))
                      (list2 (list (string-take (list-ref list1 0) 20)
                                   (list-ref list1 1)
                                   (list-ref list1 2)
                                   ($link (string-append "tmfs://commit/"
                                                         (list-ref list1 3)
                                                         (if (== (string-length name) 0)
                                                             ""
                                                             (string-append "|" name)))
                                          (string-take (list-ref list1 3) 7)))))
                 list2)))


(tm-define (git-log)
           (let* ((cmd (string-append callgit " log --pretty=%ai\"|\"%an\"|\"%s\"|\"%H"))
                  (ret1 (eval-system cmd))
                  (ret2 (string-split ret1 #\nl)))
             (define (string->commit-diff str)
                        (string->commit str ""))
             (and (> (length ret2) 0)
                  (== (cAr ret2) "")
                  (map string->commit-diff (cDr ret2)))))


(tm-define (buffer-log name)
           (let* ((name1 (url->string name))
                  (sub (string-append gitroot "/"))
                  (name-s (string-replace name1 sub ""))
                  (cmd (string-append callgit " log --pretty=%ai\"|\"%an\"|\"%s\"|\"%H " name1))
                  (ret1 (eval-system cmd))
                  (ret2 (string-split ret1 #\nl)))
             (define (string->commit-file str)
               (string->commit str name-s))
             (and (> (length ret2) 0)
                  (== (cAr ret2) "")
                  (map string->commit-file (cDr ret2)))))

(tm-define (git-versioned? buffer_url)
           (let* ((dir (url->system (url-head buffer_url)))
                  (cmd (string-append "cd " dir " && git rev-parse --show-toplevel"))
                  (ret (if (string-starts? dir "tmfs")
                           "tmfs"
                           (eval-system cmd))))
             (when (string-starts? ret "/")
                   (set! gitroot (string-drop-right ret 1))
                   (set! callgit (string-append "git --work-tree=" gitroot
                                                " --git-dir=" gitroot "/.git")))
             (display* "[debug] --git-dir= " gitroot "\n")
             (if (string-starts? gitroot "/")
                 #t
                 #f)))

(tm-define (git-compare-with-current name)
           (let* ((name-s (url->string name))
                  (file-r (cAr (string-split name-s #\|)))
                  (file (string-append gitroot "/" file-r)))
             (switch-to-buffer (string->url file))
             (compare-with-older name)))

;; FIXME
;; should compare with previous version
;; exception: if non previous version exists
(tm-define (git-compare-with-parent name)
           (let* ((name-s (string-replace (url->string name)
                                          "tmfs://commit/" ""))
                  (hash (first (string-split name-s #\|)))
                  (file (second (string-split name-s #\|)))
                  (file-buffer-s (string-append "tmfs://commit/"
                                              (git-commit-parent hash) "|"
                                              file))
                  (parent (string->url file-buffer-s)))
             (compare-with-older parent)))

(tm-define (git-compare-with-master name)
           (let* ((name-s (string-replace (url->string name)
                                          (string-append gitroot "/")
                                          "|"))
                  (file-buffer-s (string-append "tmfs://commit/"
                                                (git-commit-master)
                                                name-s))
                  (master (string->url file-buffer-s)))
             (compare-with-older master)))
