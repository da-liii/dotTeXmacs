<TeXmacs|1.99.5>

<style|<tuple|generic|british|literate>>

<\body>
  <doc-data|<doc-title|<TeXmacs> customization>|<doc-author|<author-data|<author-name|Darcy
  SHEN>>>>

  <section|Playground>

  <\scm-chunk|my-init-texmacs.scm|false|true>
    (tm-define (my-debug message)

    \ \ (tm-widget (widget1)

    \ \ \ \ \ \ \ \ \ \ \ \ \ (centered

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ (aligned

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (item (text message)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (toggle (display* "First "
    answer "\\n") #f)))))

    \ \ (top-window widget1 "Debugging"))
  </scm-chunk>

  <section|Keyboard>

  <\scm-chunk|my-init-texmacs.scm|true|false>
    (kbd-map ("M-C-n" (structured-exit-right))

    \ \ \ \ \ \ \ \ \ ("M-C-u" (structured-exit-left)))
  </scm-chunk>
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
    <associate|chunk--1|<tuple||?>>
    <associate|chunk-m-1|<tuple|m|?>>
    <associate|chunk-my--1|<tuple|my-|?>>
    <associate|chunk-my-1|<tuple|my|?>>
    <associate|chunk-my-i-1|<tuple|my-i|?>>
    <associate|chunk-my-in-1|<tuple|my-in|?>>
    <associate|chunk-my-ini-1|<tuple|my-ini|?>>
    <associate|chunk-my-init--1|<tuple|my-init-|?>>
    <associate|chunk-my-init-1|<tuple|my-init|?>>
    <associate|chunk-my-init-t-1|<tuple|my-init-t|?>>
    <associate|chunk-my-init-te-1|<tuple|my-init-te|?>>
    <associate|chunk-my-init-tex-1|<tuple|my-init-tex|?>>
    <associate|chunk-my-init-texm-1|<tuple|my-init-texm|?>>
    <associate|chunk-my-init-texma-1|<tuple|my-init-texma|?>>
    <associate|chunk-my-init-texmac-1|<tuple|my-init-texmac|?>>
    <associate|chunk-my-init-texmacs-1|<tuple|my-init-texmacs|?>>
    <associate|chunk-my-init-texmacs.-1|<tuple|my-init-texmacs.|?>>
    <associate|chunk-my-init-texmacs.s-1|<tuple|my-init-texmacs.s|?>>
    <associate|chunk-my-init-texmacs.sc-1|<tuple|my-init-texmacs.sc|?>>
    <associate|chunk-my-init-texmacs.scm-1|<tuple|my-init-texmacs.scm|?>>
    <associate|chunk-my-init-texmacs.scm-2|<tuple|my-init-texmacs.scm|?>>
    <associate|chunk-myi-1|<tuple|myi|?>>
  </collection>
</references>