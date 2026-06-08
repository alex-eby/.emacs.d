;;; org-sl.el --- Org, Denote, PDF -*- no-byte-compile: t; lexical-binding: t -*-

;; Configure org defaults
(use-package org
  :bind (("C-c l s" . #'org-store-link)
         ("C-c l i" . #'org-insert-link-global)
         ("C-c c" . #'org-capture)
         ("C-c a" . #'org-agenda))
  :custom
  ;; Critical variables
  (org-directory "~/MEGA/org/")
  (org-agenda-files '("todo.org"))
  (org-refile-targets '(("inbox.org" :maxlevel . 2)
                        (org-agenda-files :maxlevel . 5)))
  (org-archive-location "~/MEGA/org/archive.org::datetree/")

  ;; Todo State Management
  (org-todo-keywords
   '((sequence "TODO(t)" "PROJ(p)" "LOOP(r)" "STRT(s)" "WAIT(w@/!)" "HOLD(h@)" "IDEA(i)" "|"
   	           "DONE(d)" "KILL(k@)")))
  (org-log-done 'time)
  (org-log-into-drawer t)

  ;; Define list of available tags
  (org-tag-alist
   '(;; locale
     (:startgroup)
     ("@computer" . ?C)
     ("@phone" . ?P)
     ("@home" . ?H)
     ("@uni" . ?U)
     ("@transit" . ?T)
     ("@outside" . ?O)
     (:endgroup)
     (:newline)
     ;; environment
     (:startgroup)
     ("eldev" . ?e)
     ("pydev" . ?p)
     ("cdev" . ?c)
     ("webdev" . ?w)
     ("shdev" . ?s)
     ("drawing" . ?d)
     ("notes" . ?n)
     (:endgroup)
     (:newline)
     ;; scope / horizon
     (:startgroup)
     ("area" . ?1)
     ("goal" . ?2)
     ("vision" . ?3)
     (:endgroup)))

  ;; Configure tag inheritance
  (org-tags-exclude-from-inheritance '("area" "goal" "vision"))

  ;; Define capture templates for org-capture
  (org-capture-templates
   '(("c" "Capture" entry (file+headline "inbox.org" "Captured")
      "* %?\n%i")))
  :config
  (progn
    (add-to-list 'org-export-backends 'md)
    
    ;; Make org-open-at-point follow file links in the same window
    (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)))

;; Pretty org mode
(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :hook (org-agenda-finalize . org-modern-agenda)

  :custom
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  
  (org-insert-heading-respect-content t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-pretty-entities-include-sub-superscripts t)
  (org-ellipsis "…")
  :config
  ;; Carry over the default values of `org-todo-keyword-faces', `org-tag-faces',
  ;; and `org-priority-faces' as reasonably as possible, but only if the user
  ;; hasn't already modified them.
  (progn
    (defun new-spec (spec)
      (if (or (facep (cdr spec))
              (not (keywordp (car-safe (cdr spec)))))
          `(:inherit ,(cdr spec))
        (cdr spec)))
  
    (dolist (spec org-tag-faces)
      (add-to-list 'org-modern-tag-faces `(,(car spec) :inverse-video t ,@(new-spec spec))))
  
    (dolist (spec org-todo-keyword-faces)
      (add-to-list 'org-modern-todo-faces `(,(car spec) :inverse-video t ,@(new-spec spec))))
  
    (dolist (spec org-priority-faces)
      (add-to-list 'org-modern-priority-faces `(,(car spec) :inverse-video t ,@(new-spec spec)))))
  )

;; Hide markup such as the *s in *bold*
(use-package org-appear
  :ensure t
  :hook org-mode)

(provide 'org-sl)
;;; org-sl.el ends here
