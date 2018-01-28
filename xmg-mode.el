;;; xmg-mode.el --- major mode for editing XMG code

;; Author: Timm Lichte

;;; Commentary:

;; Major mode for editing XMG source files.

;; Based on Benoit Crabbé's original major mode for "metagrammars": https://sourcesup.cru.fr/xmg/xmg.el
;; Written with the help of Scott Andrew Borton's guide to writing major modes: https://www.emacswiki.org/emacs/ModeTutorial

;;; Code:

(defvar xmg-mode-hook nil)

(defvar xmg-mode-map
  (let ((map (make-keymap)))
    ;; (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for XMG major mode.")

(add-to-list 'auto-mode-alist '("\\.mg\\'" . xmg-mode))
(add-to-list 'auto-mode-alist '("\\.xmg\\'" . xmg-mode))


(defconst xmg-font-lock-keywords
	(list
	 (regexp-opt '("class"
								 "node"
								 "declare"
								 "value"
								 "<syn>"
								 "<sem>"
								 "<frame>"
								 "feature"
								 "type"
								 "property"
								 "import"
								 "export"
								 "frame-constraints"
								 "frame-types"
								 ;; "*="
								 ) 'words)
	 '("^[ \t]*class[ \t]+\\([a-zA-Z0-9_.-]*\\)" 1 'font-lock-function-name-face)
	 '("^[ \t]*feature[ \t]+\\([a-zA-Z0-9_.-]*\\)" 1 'font-lock-type-face)
	 '("^[ \t]*property[ \t]+\\([a-zA-Z0-9_.-]*\\)" 1 'font-lock-type-face)
	 '("^[ \t]*type[ \t]+\\([a-zA-Z0-9_.-]*\\)" 1 'font-lock-type-face)
	 '("^[ \t]*value[ \t]+\\([a-zA-Z0-9_.-]*\\)" 1 'font-lock-function-name-face)
	 '("^[ \t]*\\(use\\)[ \t]+\\([a-zA-Z0-9_.-=]+\\)[ \t]*\\(with\\)[ \t]+\(\\([a-zA-Z0-9_.-=]*\\)\)[ \t]+\\(dims\\)[ \t]" (1 'font-lock-builtin-face) (3 'font-lock-builtin-face) (5 'font-lock-builtin-face))
	 '("\?[a-zA-Z0-9]+" . font-lock-variable-name-face)
	 '("\![a-zA-Z0-9]+" . font-lock-constant-face)
	 )
	"Default highlighting expressions for xmg-mode."
	)

(defun xmg-indent-line ()
  "Indent current line as XMG code."
  (interactive)
	(beginning-of-line)
	(if (bobp)  ; at begin of buffer
      (indent-line-to 0)
		(let ((not-indented t)
					(cur-indent 0)
					(block-end-regexp ".*\}[ \t]*$")		; "^[ \t]*\}"
					(block-start-regexp ".*\{[ \t]*$")) ; "^[ \t]*\{"
			
			(if (looking-at "^[ \t\}]*$")			; at end of block consisting only of \}
					(progn
						(save-excursion
							(forward-line -1)
							(setq cur-indent (- (current-indentation) tab-width))))
				
				(save-excursion 								; within a block
          (while not-indented						; search backwards until an indentation hint is found
            (forward-line -1)
            (if (looking-at block-end-regexp) ; indentation hint: closing bracket
                (progn
                  (setq cur-indent (- (current-indentation) tab-width))
                  (setq not-indented nil))
																				
              (if (looking-at block-start-regexp) ; indentation hint: opening bracket
                  (progn
                    (setq cur-indent (+ (current-indentation) tab-width))
                    (setq not-indented nil))
								
                (if (bobp)							; no indentation hint found
                    (setq not-indented nil)))))))

			(if (< cur-indent 0)				; don't deindent too far
					(setq cur-indent 0))
			(if cur-indent		; finally, set indentation based on cur-indent
          (indent-line-to cur-indent)
        (indent-line-to 0))))) ; if we didn't see an indentation hint, then allow no indentation

(defvar xmg-mode-syntax-table
  (let ((st (make-syntax-table)))
		(modify-syntax-entry ?_ "w" st)			; treat underscore as a segment of a word
		(modify-syntax-entry ?- "w" st)			; treat hyphen as a segment of a word
		
		; comments
		(modify-syntax-entry ?/ ". 12" st)	; C++ style comments
    (modify-syntax-entry ?% "<" st)
		(modify-syntax-entry ?\n ">" st)
		
		st)
  "Syntax table for xmg-mode.")

(defun xmg-mode ()
  "Major mode for editing XMG files."
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table xmg-mode-syntax-table)
  (use-local-map xmg-mode-map)
	(set (make-local-variable 'font-lock-defaults) '(xmg-font-lock-keywords))
	(set (make-local-variable 'indent-line-function) 'xmg-indent-line)
	(set (make-local-variable 'comment-start) "% ")
	(set (make-local-variable 'comment-end) "")
	(setq major-mode 'xmg-mode)
  (setq mode-name "XMG")
  (run-mode-hooks 'prog-mode-hook 'xmg-mode-hook))

;; imenu support
(defvar xmg-imenu-generic-expression
      '(("class"  "^ *class *\\(.*\\)" 1)
        ("value"     "^ *value *\\(.*\\)" 1)))
(add-hook 'xmg-mode-hook
					(lambda ()
						(setq imenu-generic-expression xmg-imenu-generic-expression)))

(provide 'xmg-mode)

;;; xmg-mode.el ends here
