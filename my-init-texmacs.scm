(tm-define (my-debug message)
  (tm-widget (widget1)
             (centered
              (aligned
               (item (text message)
                     (toggle (display* "First " answer "\n") #f)))))
  (top-window widget1 "Debugging"))
(use-modules (convert markdown init-markdown))
(use-modules (utils git git-menu))
(kbd-map ("M-C-n" (structured-exit-right))
         ("M-C-u" (structured-exit-left)))
