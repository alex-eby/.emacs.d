;;; notes-sl.el --- Denote, Citations, PDF Annotation -*- no-byte-compile: t; lexical-binding: t; -*-

;; File naming scheme for consistent note storage
(use-package denote
  :ensure t
  :commands (denote
             denote-template
             denote-dired
             denote-grep)
  :bind (;; Entering denote
         ("C-c n n" . #'denote)
         ("C-c n t" . #'denote-template)
         ("C-c n d" . #'denote-dired)
         ("C-c n g" . #'denote-grep)
         ;; Interacting with denote files
         ("C-c n b" . #'denote-backlinks)
         ("C-c n r" . #'denote-rename-file)
         ("C-c n R" . #'denote-rename-file-using-front-matter)
         ;; Extra bindings in `dired'
         :map dired-mode-map
         ("C-c n r" . #'denote-dired-rename-files)
         ("C-c n k" . #'denote-dired-rename-marked-files-with-keywords)
         ("C-c n l" . #'denote-dired-link-marked-notes))
  :custom
  (denote-directory "~/MEGA/notes/")
  (denote-known-keywords '("moc" "poi"))
  (denote-prompts '(title keywords file-type))
  (denote-templates
   `((requirements . ,(concat "* Problem Statement\n\n"
                              "* Objectives / Outcomes\n\n"
                              "* Done Conditions\n\n"
                              "* Technical Details (I/O, Side Effects)\n\n"
                              "* References\n"))))

  ;; Pick dates, where relevant, with Org's advanced interface:
  (denote-date-prompt-use-org-read-date t)
  :config (denote-rename-buffer-mode))

;; Convenient daily journal
(use-package denote-journal
  :ensure t
  ;; Bind those to some key for your convenience.
  :commands (denote-journal-new-entry
             denote-journal-new-or-existing-entry
             denote-journal-link-or-create-entry)
  :bind ("C-c n j" . #'denote-journal-new-or-existing-entry)
  :hook (calendar-mode . denote-journal-calendar-mode)
  :custom
  (denote-journal-directory "~/MEGA/journal")
  (denote-journal-keyword "journal")
  (denote-journal-title-format 'day-date-month-year))

(provide 'notes-sl)
;;; notes-sl.el ends here
