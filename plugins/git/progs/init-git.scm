(import-from (git-utils) (git-tmfs))

(tm-define (git-initialize)
           (menu-bind texmacs-extra-menu
                      (=> "Git"
                          ("Log" (git-show-log))
                          ("Status" (git-show-status))
                          ("Commit" (git-interactive-commit))
                                        ;("Pull" (git-pull))
                                        ;("Push" (git-push))
                          ---
                          ;; FIXME buffer-status will be executed whenever I made changes
                          (assuming (buffer-unstaged? (current-buffer))
                                    ("Add" (git-add (current-buffer))))
                          (assuming (buffer-staged? (current-buffer))
                                    ("Undo Add" (git-unadd (current-buffer))))
                          (when (buffer-histed? (current-buffer))
                                ("History" (git-history (current-buffer)))))))

(tm-define (git-interactive-commit)
           (:interactive #t)
           (git-show-status)
           (interactive (lambda (message) (git-commit message))))

(tm-define (git-pull)
           (insert "git-pull"))

(tm-define (git-push)
           (insert "git-push"))

(tm-define (git-add name)
           (let* ((name-s (url->string name))
                  (cmd (string-append "git add " name-s))
                  (ret (eval-system cmd)))
             (set-message cmd "The file is added")))

(tm-define (git-unadd name)
           (display name)
           (let* ((name-s (url->string name))
                  (cmd (string-append "git reset HEAD " name-s))
                  (ret (eval-system cmd)))
             (set-message cmd "The file is unadded.")
             (display cmd)))

(plugin-configure git
                  (:require #t)
                  (:initialize (git-initialize)))
