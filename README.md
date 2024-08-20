# Emacs major mode for PIC using Tree-sitter

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://github.com/smoeding/pic-ts-mode/actions/workflows/CI.yaml/badge.svg)](https://github.com/smoeding/pic-ts-mode/actions/workflows/CI.yaml)

This is a major mode for [GNU Emacs](https://www.gnu.org/software/emacs/) 29.1 or later which adds support for the Pic language. Pic is a domain-specific language by Brian W. Kernighan for specifying diagrams. The mode uses a Tree-sitter parser to be able to parse the code and provide fontification, indentation, navigation and more.

## Features

The mode provides the following features and enhancements to make writing Pic diagrams easier.

### Syntax highlighting

Syntax highlighting for the following elements is implemented:

- comments
- strings (including some escape sequences)
- numbers
- variables
- primitives
- built-in functions
- macros
- labels
- corners
- keywords (`if`, `then`, `else`, `for`, `to`, `by`, `do`, ...)
- troff requests and macro calls
- syntax errors

### Indentation

Indentation for block structures is implemented.

### Navigation

The keybindings <kbd>C-M-a</kbd> and <kbd>C-M-e</kbd> jump to preceding or following element respectively.

## Installation

Emacs 29.1 or above with Tree-sitter support is required.

Also the appropriate [parser](https://github.com/smoeding/tree-sitter-pic) for the Pic language needs to be installed. The following Elisp code should be used to install the Pic language parser.  This requires some tools -- notably a compiler toolchain -- to be available on your machine.

```elisp
(require 'pic-ts-mode)
(pic-ts-mode-install-grammar)
```

Using the function provided by the package ensures that a version of the parser matching the package will be installed. These commands should also be used to update the parser to the correct version when the package is updated.

## License

Pic Tree-sitter Mode is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Pic Tree-sitter Mode is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](http://www.gnu.org/licenses/) for more details.
