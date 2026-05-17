(require 'ox-publish)

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'htmlize)
  (package-install 'htmlize))

(setq org-html-htmlize-output-type 'css)

(defun read-template (filename)
  "reads an html template file"
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(setq
 head-extra-template (read-template "templates/header.html")
 html-preamble (read-template "templates/navbar.html")
 html-postamble (read-template "templates/footer.html"))

(setq org-publish-project-alist
      '(( "test-emacs-site"
          :recursive t             
          :base-directory "./content"
          :publishing-directory "./public"
          :base-extension "org"
          :publishing-function org-html-publish-to-html
          :with-author nil
          :with-creator nil
          :with-toc t
          :section-numbers nil
          :time-stamp-file nil)
        ( "CSS"
          :base-directory "./content/css"
          :publishing-directory "./public/css"
          :base-extension "css"
          :publishing-function org-publish-attachment)
        ( "images"
          :base-directory "./content"
          :publishing-directory "./public"
          :recursive t
          :base-extension "png\\|jpg\\|jpeg\\|gif\\|svg\\|ico"
          :publishing-function org-publish-attachment)))

(setq org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil
      org-html-head head-extra-template
      org-html-preamble html-preamble
      org-html-postamble html-postamble)
      ;; org-html-head "<link rel=\"stylesheet\" href=\"/css/style.css\" /> <link rel=\"stylesheet\" href=\"/css/fonts.css\" /> <link rel=\"icon\" href=\"/images/favicon-32x32.png\" />")

(org-publish-all t)

(message "Build Complete!")
