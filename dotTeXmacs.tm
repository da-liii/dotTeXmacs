<TeXmacs|1.99.5>

<style|<tuple|tmdoc|british|literate>>

<\body>
  <tmdoc-title|TeXmacs customization>

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

  <section|Plugins>

  <\scm-chunk|my-init-texmacs.scm|true|true>
    (use-modules (convert markdown init-markdown))

    (use-modules (utils git git-menu))
  </scm-chunk>

  <section|Keyboard>

  <\scm-chunk|my-init-texmacs.scm|true|false>
    (kbd-map ("M-C-n" (structured-exit-right))

    \ \ \ \ \ \ \ \ \ ("M-C-u" (structured-exit-left)))
  </scm-chunk>

  \;

  <tmdoc-copyright|2017|Darcy Shen>

  <tmdoc-license|Permission is granted to copy, distribute and/or modify this
  document under the terms of the GNU Free Documentation License, Version 1.1
  or any later version published by the Free Software Foundation; with no
  Invariant Sections, with no Front-Cover Texts, and with no Back-Cover
  Texts. A copy of the license is included in the section entitled "GNU Free
  Documentation License".>
</body>

<initial|<\collection>
</collection>>