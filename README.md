# Pandoc Acronym Filter

Pandoc LUA filter for parsing MMD acronym syntax for HTML and Latex output.

## Script

```
pandoc -s -f markdown -t html --lua-filter pandoc-acronym-filter.lua demo.md -o demo.html
pandoc -s -f markdown -t latex --lua-filter pandoc-acronym-filter.lua demo.md -o demo.tex
```

## Input

```md
You can use CSS to style your HTML.

*[CSS]: Cascading Style Sheets

*[HTML]: Hyper Text Markup Language
```

## Output

### HTML

```html
<p>You can use <abbr title="Cascading Style Sheets">CSS</abbr> to style your <abbr title="HyperText Markup Language">HTML</abbr>.</p>
```

### Latex

```latex
You can use \ac{CSS} to style your \ac{HTML}.

\begin{acronym}
    \acro{CSS}{Cascading Style Sheets}
    \acro{HTML}{Hyper Text Markup Language}
\end{acronym}
```

## Features

### Benefits

* The filter will match the acronym even if it is followed by punctuation.
* The filter will match the acronym even if it is an English plural (has an `s` suffix).

#### Latex

* Acronyms will appear in long form the first instance and the following instances in short form.
* List of acronyms are in alphabetical order.
* Uses the `acronym` package.

### Limitations

* Each acronym definition must be on their own line with a blank line between them.
* The filter will not match an acronym if it is followed by an ellipsis.
* Will not work for acronyms which are plural without `s` suffix, for example, Systems on a Chip (SOACs).
