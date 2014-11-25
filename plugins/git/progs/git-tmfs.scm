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
                                `(document
                                  (TeXmacs "1.99.2")
                                  (style (tuple "generic" "chinese"))
                                  (body ,(cons 'document s)))))
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
                                                             ($inline "Commit " commit " by " by " on " date)
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

(tmfs-load-handler (commit name)
                   (if (string-contains name "|")
                       (git-show (string-replace name "|" ":./"))
                       (with m (git-commit-message name)
                             (with p (git-commit-parent name)
                                   (with d (git-commit-diff p name)
                                         ($generic
                                          ($tmfs-title "Commit Message of " (string-take name 7))
                                          (if (== name p)
                                              "parent 0"
                                              `(concat "parent " ,($link (string-append "tmfs://commit/" p) p)))
                                          (list 'new-line)
                                          ($for (x m) `(concat ,(utf8->cork x) ,(list 'new-line)))
                                          "----"
                                          (list 'new-line)
                                          ($for (x d) `(concat ,(utf8->cork x) ,(list 'new-line)))))))))

