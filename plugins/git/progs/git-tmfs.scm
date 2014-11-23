(texmacs-module (git-tmfs))

(import-from (git-utils))

(tm-define (git-show-status)
           (cursor-history-add (cursor-path)) ;; FIXME: the meaning of this line
           (revert-buffer "tmfs://git/status"))

(tm-define (git-show-log)
           (cursor-history-add (cursor-path)) ;; FIXME: the meaning of this line
           (revert-buffer "tmfs://git/log"))

(tmfs-title-handler (git name doc)
                    (cond ((== name "status") "git status")
                          ((== name "log") "git log")
                          (else "unknown")))

(tmfs-load-handler (git name)
                   (cond ((== name "status")
                          (with s (git-status)
                                `(document
                                  (TeXmacs "1.99.2")
                                  (style (tuple "generic" "chinese"))
                                  (body ,(cons 'document s)))))
                         ((== name "log")
                          (with s (git-log)
                                `(document
                                  (TeXmacs "1.99.2")
                                  (style (tuple "generic" "chinese"))
                                  (body ,(cons 'document s)))))
                         (else '())))

(tm-define (git-history name)
           (cursor-history-add (cursor-path)) ;; FIXME: the meaning of this line
           (with s (url->tmfs-string name)
                 (revert-buffer (string-append "tmfs://history/" s))))

(tmfs-title-handler (history name doc)
                    (with u (tmfs-string->url name)
                          (string-append (url->system (url-tail u)) " - History")))

(tmfs-load-handler (history name)
                   (with u (tmfs-string->url name)
                         (with h (buffer-log u)
                               `(document
                                  (TeXmacs "1.99.2")
                                  (style (tuple "generic" "chinese"))
                                  (body ,(cons 'document h))))))
