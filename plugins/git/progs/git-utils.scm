(texmacs-module (git-utils))

(define gitroot "invalid")

(define callgit
  "git")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; git add, unadd, history, compare
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

(tm-define (buffer-log name)
           (let* ((name1 (url->string name))
                  (sub (string-append gitroot "/"))
                  (name-s (string-replace name1 sub ""))
                  (cmd (string-append
                        callgit " log --pretty=%ai\"|\"%an\"|\"%s\"|\"%H "
                        name1))
                  (ret1 (eval-system cmd))
                  (ret2 (string-split ret1 #\nl)))
             (define (string->commit-file str)
               (string->commit str name-s))
             (and (> (length ret2) 0)
                  (== (cAr ret2) "")
                  (map string->commit-file (cDr ret2)))))

(tm-define (git-compare-with-current name)
           (let* ((name-s (url->string name))
                  (file-r (cAr (string-split name-s #\|)))
                  (file (string-append gitroot "/" file-r)))
             (switch-to-buffer (string->url file))
             (compare-with-older name)))

(tm-define (git-compare-with-parent name)
           (let* ((name-s (string-replace (url->string name)
                                          "tmfs://commit/" ""))
                  (hash (first (string-split name-s #\|)))
                  (file (second (string-split name-s #\|)))
                  (file-buffer-s (string-append
                                  "tmfs://commit/"
                                  (git-commit-file-parent file hash) "|"
                                  file))
                  (parent (string->url file-buffer-s)))
             (if (== name parent)
                 (set-message "No parent" "No parent")
                 (compare-with-older parent))))

(tm-define (git-compare-with-master name)
           (let* ((name-s (string-replace (url->string name)
                                          (string-append gitroot "/")
                                          "|"))
                  (file-buffer-s (string-append "tmfs://commit/"
                                                (git-commit-master)
                                                name-s))
                  (master (string->url file-buffer-s)))
             (compare-with-older master)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; git status, log, commit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

(tm-define (git-log)
           (let* ((cmd (string-append
                        callgit
                        " log --pretty=%ai\"|\"%an\"|\"%s\"|\"%H"))
                  (ret1 (eval-system cmd))
                  (ret2 (string-split ret1 #\nl)))
             (define (string->commit-diff str)
                        (string->commit str ""))
             (and (> (length ret2) 0)
                  (== (cAr ret2) "")
                  (map string->commit-diff (cDr ret2)))))

(tm-define (git-commit message)
           (let* ((cmd (string-append
                        callgit " commit -m \"" message "\""))
                  (ret (eval-system cmd)))
             ;; (display ret)
             (set-message (string-append callgit " commit") message))
           (git-show-status))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; basic routines for buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(tm-define (git-versioned? name)
           (let* ((dir (url->system (url-head name)))
                  (cmd (string-append "cd " dir
                                      " && git rev-parse --show-toplevel"))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; low level routines for git (involving hash code)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(tm-define (git-show object)
           (let* ((cmd (string-append callgit " show " object))
                  (ret (eval-system cmd)))
             ;; (display* "\n" cmd "\n" ret "\n")
             ret))

(tm-define (git-commit-message hash)
           (let* ((cmd (string-append callgit " log -1 " hash))
                  (ret (eval-system cmd)))
             (string-split ret #\nl)))

(tm-define (git-commit-parent hash)
           (let* ((cmd (string-append
                        callgit " log -2 --pretty=%H " hash
                        " | tail -1"))
                  (ret (eval-system cmd)))
             (string-drop-right ret 1)))

(tm-define (git-commit-file-parent file hash)
           (let* ((cmd (string-append
                        callgit " log --pretty=%H "
                        gitroot "/" file))
                  (ret (eval-system cmd))
                  (ret2 (string-decompose
                         ret (string-append hash "\n"))))
             ;; (display ret2)
             (if (== (length ret2) 1)
                 hash
                 (string-take (second ret2) 40))))

(tm-define (git-commit-master)
           (let* ((cmd (string-append callgit " log -1 --pretty=%H"))
                  (ret (eval-system cmd)))
             (string-drop-right ret 1)))

(tm-define (git-commit-diff parent hash)
           (let* ((cmd (if (== parent hash)
                           (string-append
                            callgit " show " hash
                            " --numstat --pretty=oneline | tail -n +2")
                           (string-append
                            callgit " diff --numstat "
                            parent " " hash)))
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
