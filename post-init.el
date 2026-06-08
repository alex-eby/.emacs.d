;;; post-init.el --- Main personal config -*- no-byte-compile: t; lexical-binding: t; -*-

;; Set default font
(set-face-attribute 'default nil
                    :height 100 :weight 'regular :family "Hack Nerd Font")

;; Doom theme collection
(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)

  :config
  (progn
    ;; Default to `doom-nord' theme
    (load-theme 'doom-nord t)

    ;; Configure theming for treemacs
                                        ;(setopt doom-themes-treemacs-theme "doom-atom")
                                        ;(doom-themes-treemacs-config)

    ;; Enhance `org-mode' fontification (conflict with org-modern?)
    (doom-themes-org-config)))

;; A /really/ nice mode line
(use-package doom-modeline
  :ensure t
  :custom (doom-modeline-height 27)
  :init (doom-modeline-mode))

;; Highlight TODO, NOTE, and similar tags in code
(require 'hl-codetags)
(add-hook 'prog-mode-hook #'highlight-codetags-local-mode)

;; Near-instant matching paren hl
(setopt show-paren-delay 0.05)

;; Smooth scrolling
(pixel-scroll-precision-mode)

;; Do not overwrite externally copied text on kill
(setopt save-interprogram-paste-before-kill t)

;; Overwrite selection with any input
(delete-selection-mode)

;; Guarantee shell PATH is in the environment
(use-package exec-path-from-shell
  :ensure t
  :init (exec-path-from-shell-initialize))

;; Contextual help menus
(use-package helpful
  :ensure t
  :commands (helpful-callable
             helpful-variable
             helpful-key
             helpful-command
             helpful-at-point
             helpful-function)
  :bind (([remap describe-command] . helpful-command)
         ([remap describe-function] . helpful-callable)
         ([remap describe-key] . helpful-key)
         ([remap describe-symbol] . helpful-symbol)
         ([remap describe-variable] . helpful-variable)))

(define-advice keyboard-quit (:around (quit) quit-current-context)
  "DWIM-style augmentation for `keyboard-quit'.

Active minibuffer command => Quit Minibuffer
Defining macro => Record input
Else => `keyboard-quit'"
  (if (active-minibuffer-window)
      (if (minibufferp)
          (minibuffer-keyboard-quit)
        (abort-recursive-edit))
    (unless (or defining-kbd-macro
                executing-kbd-macro)
      (funcall-interactively quit))))

;; Improved undo/redo functionality
(use-package undo-fu
  :ensure t
  :bind (("C-_" . #'undo-fu-only-undo)
         ("C-M-_" . #'undo-fu-only-redo)))

;; Save undo history across sessions
(use-package undo-fu-session
  :ensure t
  :hook (elpaca-after-init . #'undo-fu-session-global-mode))

;; Automatic buffer cleanup
(use-package buffer-terminator
  :ensure t
  :config (buffer-terminator-mode))

;; Replace buffer list with more powerful `ibuffer'
(advice-add 'list-buffers :override #'ibuffer-other-window)

;; Automatically reread a changed file to its buffer(s)
(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook (elpaca-after-init . #'global-auto-revert-mode)
  :custom
  (auto-revert-interval 3)
  (auto-revert-check-vc-info t)
  (auto-revert-remote-files nil)
  (auto-revert-avoid-polling t))

;; Maintain a list of recently visited files
(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook ((elpaca-after-init . recentf-mode)
         (kill-emacs . #'recentf-cleanup))
  :init
  (progn
    (setq recentf-auto-cleanup (if (daemonp) 300 'never))
    (setq recentf-exclude
          (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
                "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
                "\\.7z$" "\\.rar$"
                "COMMIT_EDITMSG\\'"
                "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                "-autoloads\\.el$" "autoload\\.el$")))
  :config (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; Save minibuffer history between sessions
(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook (elpaca-after-init . #'savehist-mode)
  :custom (history-length 300))

;; Automatically restore previous mark position upon reopening a file
(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook (elpaca-after-init . #'save-place-mode))

;; Proper markdown support
(use-package markdown-mode
  :ensure t
  :commands (gfm-mode
             gfm-view-mode
             markdown-mode
             markdown-view-mode)
  :mode (("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind (:map markdown-mode-map
              ("M-." . markdown-do)))

;; Enable tree-sitter in all available modes
(setopt treesit-enabled-modes t)

;; Maximize syntax-based highlighting
(setopt treesit-font-lock-level 4)

;; Ask to install language grammars when needed
(setopt treesit-auto-install-grammar 'ask)

;; Code folding powered by tree-sitter
(use-package treesit-fold
  :ensure t
  :commands (treesit-fold-close
             treesit-fold-close-all
             treesit-fold-open
             treesit-fold-toggle
             treesit-fold-open-all
             treesit-fold-mode
             global-treesit-fold-mode
             treesit-fold-open-recursively
             treesit-fold-line-comment-mode)

  :custom
  (treesit-fold-line-count-show t)
  (treesit-fold-line-count-format " ▼")

  :config
  (progn
    ;; Prettify the fold indicator
    (set-face-attribute 'treesit-fold-replacement-face nil
                        :foreground "#808080"
                        :box nil
                        :weight 'bold)

    ;; Enable `treesit-fold-mode' in all supported buffers
    (global-treesit-fold-mode +1)))

;; Code folding not powered by tree-sitter
(add-hook 'emacs-lisp-mode-hook #'hs-minor-mode)

(defun my/pretty-fold-icon ()
  "Replace '...' with ' ▼' in `outline-minor-mode'."
  (let* ((display-table (or buffer-display-table (make-display-table)))
         (face-offset (* (face-id 'shadow) (ash 1 22)))
         (value (vconcat (mapcar (lambda (c) (+ face-offset c)) " ▼"))))
    (set-display-table-slot display-table 'selective-display value)
    (setq buffer-display-table display-table)))

;; Guarantee hook ordering: prettify->enable
(progn
  (add-hook 'outline-minor-mode-hook #'my/pretty-fold-icon)
  (add-hook 'markdown-mode-hook #'outline-minor-mode)
  (add-hook 'gfm-mode-hook #'outline-minor-mode))

;; Unified folding for many different modes
(use-package kirigami
  :ensure t
  :commands (kirigami-open-fold
             kirigami-open-fold-rec
             kirigami-close-fold
             kirigami-toggle-fold
             kirigami-open-folds
             kirigami-close-folds-except-current
             kirigami-close-folds)
  :bind
  (("C-c z o" . #'kirigami-open-fold)          ; Open fold at point
   ("C-c z O" . #'kirigami-open-fold-rec)      ; Open fold recursively
   ("C-c z r" . #'kirigami-open-folds)         ; Open all folds
   ("C-c z c" . #'kirigami-close-fold)         ; Close fold at point
   ("C-c z m" . #'kirigami-close-folds)        ; Close all folds
   ("C-c z z" . #'kirigami-toggle-fold)))      ; Toggle fold at point

(let ((modules-dir (expand-file-name "modules/" minimal-emacs-user-directory)))
  (add-to-list 'load-path modules-dir)

  (require 'completion-sl)
  (require 'org-sl)
  (require 'prog-sl)
  (require 'notes-sl))
