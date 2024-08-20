;;; pic-ts-mode.el --- Major mode for Pic using Tree-sitter -*- lexical-binding: t; -*-

;; Copyright (c) 2024  Stefan Möding

;; Author:           Stefan Möding <stm@kill-9.net>
;; Maintainer:       Stefan Möding <stm@kill-9.net>
;; Version:          0.1.0
;; Created:          <2024-07-31 13:53:08 stm>
;; Updated:          <2024-08-20 17:30:14 stm>
;; URL:              https://github.com/smoeding/pic-ts-mode
;; Keywords:         languages
;; Package-Requires: ((emacs "29.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package uses a Tree-sitter parser to provide syntax highlighting,
;; indentation and navigation for the Pic language.  Pic is a domain-specific
;; language by Brian W. Kernighan for specifying diagrams.
;;
;; Syntax highlighting: Fontification is supported using custom faces for Pic
;;   syntax elements like comments, strings, variables and keywords.  Syntax
;;   errors can be shown using a warning face by setting
;;   `treesit-font-lock-level' to 4.
;;
;; Indentation: Pic is simple language and does not use sophisticated
;;   indentation rules so only simple block indentation is provided.
;;
;; The package uses a Tree-sitter library to parse Pic code and you need to
;; install the appropriate parser.  It can be done by using this Elisp code:
;;
;;    (require 'pic-ts-mode)
;;    (pic-ts-mode-install-grammar)
;;
;; Note that a C compiler is required for this step.  Using the function
;; provided by the package ensures that a version of the parser matching the
;; package will be installed.  These commands should also be used to update
;; the parser to the correct version when the package is updated.
;;

;;; Code:


;; Requirements

(require 'treesit)


;; Customization

(defgroup pic-ts nil
  "Create Pic diagrams in Emacs."
  :prefix "pic-ts-"
  :group 'languages
  :link '(url-link :tag "Repository" "https://github.com/smoeding/pic-ts-mode"))


;; Faces

(defface pic-ts-comment
  '((t :inherit font-lock-comment-face))
  "Face for comments."
  :group 'pic-ts)

(defface pic-ts-string
  '((t :inherit font-lock-string-face))
  "Face for strings."
  :group 'pic-ts)

(defface pic-ts-escape
  '((t :inherit font-lock-escape-face))
  "Face for escape sequences."
  :group 'pic-ts)

(defface pic-ts-keyword
  '((t :inherit font-lock-keyword-face))
  "Face for keywords."
  :group 'pic-ts)

(defface pic-ts-command-line
  '((t :inherit font-lock-preprocessor-face))
  "Face for command lines."
  :group 'pic-ts)

(defface pic-ts-builtin
  '((t :inherit font-lock-builtin-face))
  "Face for built-in functions."
  :group 'pic-ts)

(defface pic-ts-constant
  '((t :inherit font-lock-constant-face))
  "Face for a constant."
  :group 'pic-ts)

(defface pic-ts-variable-name
  '((t :inherit font-lock-variable-name-face))
  "Face for the name of a variable."
  :group 'pic-ts)

(defface pic-ts-variable-use
  '((t :inherit font-lock-variable-use-face))
  "Face for the name of a variable being referenced."
  :group 'pic-ts)

(defface pic-ts-function-name
  '((t :inherit font-lock-function-name-face))
  "Face for the name of a function or macro."
  :group 'pic-ts)

(defface pic-ts-function-call
  '((t :inherit font-lock-function-call-face))
  "Face for the name of a function or macro being called."
  :group 'pic-ts)

(defface pic-ts-number
  '((t :inherit font-lock-number-face))
  "Face for numbers."
  :group 'pic-ts)

(defface pic-ts-corner
  '((t :inherit font-lock-property-use-face))
  "Face for corners."
  :group 'pic-ts)

(defface pic-ts-bracket
  '((t :inherit font-lock-bracket-face))
  "Face for brackets."
  :group 'pic-ts)

(defface pic-ts-negation-char
  '((t :inherit font-lock-negation-char-face))
  "Face for the negation char."
  :group 'pic-ts)

(defface pic-ts-operator
  '((t :inherit font-lock-operator-face))
  "Face for operators."
  :group 'pic-ts)

(defface pic-ts-warning
  '((t :inherit font-lock-warning-face))
  "Face for language errors found by the parser."
  :group 'pic-ts)


;; Language grammar

(defconst pic-ts-mode-treesit-language-source
  '(pic . ("https://github.com/smoeding/tree-sitter-pic"))
  "The language source entry for the associated Pic language parser.

The value refers to the specific version of the parser that the
mode has been tested with.  Using this mode with either an older
or newer version of the parser might not work as expected.")

(defun pic-ts-mode-install-grammar ()
  "Install the language grammar for `pic-ts-mode'.

The function removes existing entries for the Pic language in
`treesit-language-source-alist' and adds the entry stored in
`pic-ts-mode-treesit-language-source'."
  (interactive)
  ;; Remove existing entries
  (setq treesit-language-source-alist
        (assq-delete-all 'pic treesit-language-source-alist))
  ;; Add the correct entry
  (add-to-list 'treesit-language-source-alist
               pic-ts-mode-treesit-language-source)
  ;; Install the grammar
  (treesit-install-language-grammar 'pic))


;; Font-Lock

(defvar pic-ts--builtin-functions-regex
  (regexp-opt
   '("atan2" "cos" "exp" "int" "log" "max" "min" "rand" "sin" "sqrt" "srand")
   'words)
  "Regular expression matchin all builtin functions used in Pic.")

(defvar pic-ts-mode-feature-list
  ;; Level 1 usually contains only comments and definitions.
  ;; Level 2 usually adds keywords, strings, data types, etc.
  ;; Level 3 usually represents full-blown fontifications, including
  ;; assignments, constants, numbers and literals, etc.
  ;; Level 4 adds everything else that can be fontified: delimiters,
  ;; operators, brackets, punctuation, all functions, properties,
  ;; variables, etc.
  '((comment)
    (keyword command string)
    (constant number variable escape-sequence builtin function corner)
    (error))
  "`treesit-font-lock-feature-list' for `pic-ts-mode'.")

(defvar pic-ts-mode-font-lock-settings
  `( ;;
    :feature comment
    :language pic
    ((comment) @pic-ts-comment)

    :feature string
    :language pic
    (((text) @pic-ts-string)
     ((data_table_tag) @pic-ts-string))

    :feature escape-sequence
    :language pic
    :override t
    ((text (escape_sequence) @pic-ts-escape))

    :feature constant
    :language pic
    ((label) @pic-ts-constant)

    :feature variable
    :language pic
    ((assignment lhs: (variable) @pic-ts-variable-name)
     ((variable) @pic-ts-variable-use)
     ((macroparameter) @pic-ts-variable-use))

    :feature number
    :language pic
    ((number) @pic-ts-number)

    :feature function
    :language pic
    ((function_call (func) @pic-ts-builtin
                    (:match ,pic-ts--builtin-functions-regex @pic-ts-builtin))
     (function_call (func) @pic-ts-function-call)
     (define (macroname) @pic-ts-function-name)
     (undef (macroname) @pic-ts-function-name))

    :feature keyword
    :language pic
    (((primitive) @pic-ts-builtin)
     ((direction) @pic-ts-builtin)
     ((object_type) @pic-ts-builtin)
     ((if ["if" "then" "else"] @pic-ts-keyword))
     ((for ["for" "to" "by" "do"] @pic-ts-keyword))
     ((copy ["copy" "thru" "until"] @pic-ts-keyword))
     ((sh "sh" @pic-ts-keyword))
     ((print "print" @pic-ts-keyword))
     ((reset "reset" @pic-ts-keyword))
     ((define "define" @pic-ts-keyword))
     ((undef "undef" @pic-ts-keyword)))

    :feature corner
    :language pic
    ((corner) @pic-ts-corner)

    :feature command
    :language pic
    ((command_line) @pic-ts-command-line)

    :feature error
    :language pic
    :override t
    ((ERROR) @pic-ts-warning))
  "`treesit-font-lock-settings' for `pic-ts-mode'.")


;; Indentation

(defcustom pic-ts-indent-level 2
  "Number of spaces for each indententation step."
  :group 'pic-ts
  :type 'integer
  :safe 'integerp)

(defcustom pic-ts-indent-tabs-mode nil
  "Indentation can insert tabs in Pic mode if this is non-nil."
  :group 'pic-ts
  :type 'boolean
  :safe 'booleanp)

(defvar pic-ts-indent-rules
  `((pic
     ;; top-level elements start in column zero
     ((parent-is "picture") column-0 0)
     ;; closing blocks
     ((node-is "]") grand-parent 0)
     ((node-is "}") grand-parent 0)
     ;; Special cases for if/for statements
     ((n-p-gp nil "delimited" "if") grand-parent pic-ts-indent-level)
     ((n-p-gp nil "delimited" "for") grand-parent pic-ts-indent-level)
     ;; (delimited) blocks
     ((parent-is "block") parent-bol pic-ts-indent-level)
     ((parent-is "delimited") parent-bol pic-ts-indent-level)
     ;; default
     (catch-all parent-bol 0)))
  "Indentation rules for `pic-ts-mode'.")


;; Major mode definition

(defvar pic-ts-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Strings
    (modify-syntax-entry ?\" "\"\"" table)
    ;; Line comments
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    ;; The dollar sign is a prefix for macro parameters
    (modify-syntax-entry ?$ "'" table)
    ;; The backslash is our escape character
    (modify-syntax-entry ?\\ "\\" table)
    ;; Our parenthesis, braces and brackets
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)
    table)
  "Syntax table for `pic-ts-mode' buffers.")

;;;###autoload
(define-derived-mode pic-ts-mode prog-mode "Pic"
  "Major mode for editing Pic files, using the Tree-sitter library.
\\<pic-ts-mode-map>
Syntax highlighting for standard Pic elements (primitives,
comments, strings, variables, keywords, functions) is available.
You can customize the variable `treesit-font-lock-level' to
control the level of fontification.

The mode needs the Tree-sitter parser for Pic code.  A parser
suitable for the current package version can be installed using
the function `pic-ts-mode-install-grammar'.  Some development
tools (C compiler, ...) are required for this.

Indentation and fontification depend on the concrete syntax tree
returned by the Tree-sitter parser.  So errors like a missing
closing parenthesis or bracket can lead to wrong indentation or
missing fontification.  This is easily resolved by fixing the
particular syntax error.

\\{pic-ts-mode-map}"
  (setq-local require-final-newline mode-require-final-newline)

  ;; Comments
  (setq-local comment-start "#")
  (setq-local comment-end "")
  (setq-local comment-start-skip "#+[ \t]*")

  ;; Treesitter
  (when (treesit-ready-p 'pic)
    (treesit-parser-create 'pic)

    ;; Navigation
    (setq treesit-defun-type-regexp "element")

    ;; Font-Lock
    (setq treesit-font-lock-feature-list pic-ts-mode-feature-list)
    (setq treesit-font-lock-settings (apply #'treesit-font-lock-rules
                                            pic-ts-mode-font-lock-settings))

    ;; Indentation
    (setq indent-tabs-mode pic-ts-indent-tabs-mode)
    (setq treesit-simple-indent-rules pic-ts-indent-rules)

    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.pic\\'" . pic-ts-mode))

;;;###autoload
(add-to-list 'magic-mode-alist '("^\\.PS\\>" . pic-ts-mode))

(provide 'pic-ts-mode)

;;; pic-ts-mode.el ends here
