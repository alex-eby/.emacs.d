;;; completion-sl.el --- VOMPECCC Completion Framework -*- no-byte-compile: t; lexical-binding: t; -*-

;; Minibuffer completion interface
(use-package vertico
  :ensure t
  :custom (vertico-cycle t)
  :config (vertico-mode))

;; Orderless completion style
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-styles-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

;; Annotations in the minibuffer completion interface
(use-package marginalia
  :commands (marginalia-mode)
  :hook (elpaca-after-init . marginalia-mode))

;; Smarter completion candidate sorting
(use-package prescient
  :ensure t)
(use-package vertico-prescient
  :ensure t
  :after (vertico prescient)
  :init (vertico-prescient-mode))
(use-package corfu-prescient
  :ensure t
  :after (corfu prescient)
  :init (corfu-prescient-mode))

;; Powerful contextual options
(use-package embark
  :ensure t
  :commands (embark-act embark-dwim embark-bindings)
  :bind (("M-." . #'embark-dwim)
         ("C-." . #'embark-act)
         ("C-h B" . #'embark-bindings))
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Glue for embark and consult
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook (embark-collect-mode . #'consult-preview-at-point-mode))

;; More powerful search and navigation
(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ("<f5>" . consult-theme)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s f" . consult-fd)
         ("M-s G" . consult-git-grep)
         ("M-s g" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ("M-s m" . consult-man) ; [S]earch man pages
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))
  :custom
  (register-preview-delay 0.5)
  (register-preview-function #'consult-register-format)

  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  :config
  (progn
    (advice-add #'register-preview :override #'consult-register-window)
    (consult-customize
     consult-theme :preview-key '(:debounce 0.2 any)
     consult-ripgrep consult-git-grep consult-grep
     consult-bookmark consult-recent-file consult-xref
     consult-source-bookmark consult-source-file-register
     consult-source-recent-file consult-source-project-recent-file
     ;; :preview-key "M-."
     :preview-key '(:debounce 0.4 any))))

;; In-buffer completion enhancement
(use-package corfu
  :custom
  (corfu-popupinfo-delay '(1 . 0.2))
  (corfu-popupinfo-hide nil)
  :init
  (progn
    (global-corfu-mode)
    (corfu-popupinfo-mode)
    (corfu-history-mode)))

;; Completion providers
(use-package cape
  :ensure t
  :bind ("M-<tab>" . #'cape-prefix-map)
  :init
  (progn
    (add-hook 'completion-at-point-functions #'cape-dabbrev)
    (add-hook 'completion-at-point-functions #'cape-file)
    (add-hook 'completion-at-point-functions #'cape-elisp-block)))

(provide 'completion-sl)
;;; completion-sl.el ends here
