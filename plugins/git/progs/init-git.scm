(import-from (git-utils) (git-tmfs))

(tm-define (git-initialize)
  (menu-bind
   texmacs-extra-menu
   (=> "Git"
       (when (git-versioned? (current-buffer))
         ("Log" (git-show-log))
         ("Status" (git-show-status))
         ("Commit" (git-interactive-commit))
         ---
         (assuming (buffer-to-add? (current-buffer))
                   ("Add" (git-add (current-buffer))))
         (assuming (buffer-to-unadd? (current-buffer))
                   ("Undo Add" (git-unadd (current-buffer))))
         (when (buffer-histed? (current-buffer))
           ("History" (git-history (current-buffer))))
         (=> "Compare"
             (assuming (buffer-tmfs? (current-buffer))
                       ("With current version"
                        (git-compare-with-current (current-buffer))))
             (assuming (buffer-tmfs? (current-buffer))
                       ("With parent version"
                        (git-compare-with-parent (current-buffer))))
             (when (and (not (buffer-tmfs? (current-buffer)))
                        (buffer-has-diff? (current-buffer)))
               ("With the master"
                (git-compare-with-master (current-buffer)))))))))

(tm-define (git-interactive-commit)
  (:interactive #t)
  (git-show-status)
  (interactive (lambda (message) (git-commit message))))

(plugin-configure git
  (:require #t)
  (:initialize (git-initialize)))
