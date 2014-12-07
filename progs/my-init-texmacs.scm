(tm-define (my-debug message)
  (tm-widget (widget1)
             (centered
              (aligned
               (item (text message)
                     (toggle (display* "First " answer "\n") #f)))))
  (top-window widget1 "Debugging"))
