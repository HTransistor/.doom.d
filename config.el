;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "HTransistor")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 14))
(setq doom-font (font-spec :family "Source Code Pro" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
(load-theme 'doom-palenight t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
;; SPACE-t-l to toggle between different linenumbers
;; (setq display-line-numbers-type 'relative)

;;no confirm messages when kill
(setq confirm-kill-emacs nil)

(global-visual-line-mode t)
(setq-default word-wrap t)

;; line breaking
(setq comment-indent-new-line nil)
(setq indent-new-comment-line nil)
(setq comment-line-break-function nil)
(setq +default-want-RET-continue-comments nil)
;; (setq-hook! 'text-mode-hook comment-line-break-function nil)

(require 'doc-view)
(setq! doc-view-resolution 144)

;; ====================================
;; Development Setup
;; ====================================

;; Enable company
(defun company-jedi-setup ()
  (add-to-list 'company-backends 'company-jedi))
(add-hook 'python-mode-hook 'company-jedi-setup)
(setq jedi:setup-keys t)
(setq jedi:complete-on-dot t)
(add-hook 'python-mode-hook 'jedi:setup)
;; C-SPC show autocompletion suggestions

(use-package! company-jedi
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t)
  )

;; nice icon when autocomplete
(use-package! company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

;; Enable Flycheck
(add-hook 'after-init-hook 'global-flycheck-mode)
(setq flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list)
;; (add-hook 'flycheck-mode-hook 'flycheck-mode)
;; SPC c x (C-c ! l) flycheck-color-mode-line


;; Enable autopep8
(require 'py-autopep8)
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save);; Enable Flycheck

;; ;; Use IPython for REPL
(setq
 python-shell-interpreter "ipython"
 python-shell-interpreter-args "-i")
;; (C-c C-c)	python-shell-send-buffer
;; (C-c C-l)	python-shell-send-file
;; (C-c C-r)	python-shell-send-region
;; (C-c C-s)	python-shell-send-string
;; (C-c C-z)	python-shell-switch-to-shell

(setq TeX-view-program-selection '((output-pdf "Zathura")))

(defun my-preview-latex ()
  "Preview LaTeX from the current cell in a separate buffer.

Handles only markdown and code cells, but both in a bit different
ways: on the former, its input is being rendered, while on the
latter - its output."
  (interactive)
  (let* ((cell (ein:worksheet-get-current-cell))
	 (text-to-render
	  (cond ((ein:markdowncell-p cell) (slot-value cell :input))
		((ein:codecell-p cell)
		 (plist-get (car (cl-remove-if-not
				  (lambda (e) (string= (plist-get e :name) "stdout"))
				  (slot-value cell :outputs)))
			    :text))
		(t (error "Unsupported cell type"))))
	 (buffer (get-buffer-create " *ein: LaTeX preview*")))
    (with-current-buffer buffer
      (when buffer-read-only
	(toggle-read-only))
      (unless (= (point-min) (point-max))
	(delete-region (point-min) (point-max)))
      (insert text-to-render)
      (goto-char (point-min))
      (org-mode)
      (org-toggle-latex-fragment 16)
      (special-mode)
      (unless buffer-read-only
	(toggle-read-only))
      (display-buffer
       buffer
       '((display-buffer-below-selected display-buffer-at-bottom)
         (inhibit-same-window . t)))
      (fit-window-to-buffer (window-in-direction 'below)))))
(use-package! ein
  :config
  (setq ob-ein-languages
   (quote
    (("ein-python" . python))))
)


(use-package! ein
  :config
  (setq ob-ein-languages
   (quote
    (("ein-python" . python))))
)
(after! ein:ipynb-mode
  (poly-ein-mode 1)
  (hungry-delete-mode -1)
  )
(setq ein:output-area-inlined-images t)

(map! :leader
      :desc "neotree"
      "o n" #'neotree-toggle)

(map! :leader
      :desc "vterm-toggle"
      "o t" #'vterm-toggle)

(map! :leader
      :desc "vterm-toggle-insert-cd"
      "o c" #'vterm-toggle-insert-cd)

(map! :leader
      :desc "ein-execute-notebook"
      "c RET" #'ein:worksheet-execute-all-cells)

(map! :leader
      :desc "latex inline preview"
      "c l" #'my-preview-latex)

(map! :leader
      :desc "latex preview toggle"
      "t t" #'latex-preview-pane-mode)

;; User-Defined init.el ends here
