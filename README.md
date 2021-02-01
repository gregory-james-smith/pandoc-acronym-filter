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

### Features

* The filter will match the acronym even if it is followed by punctuation.
* The filter will match the acronym even if it is plural (has an `s` suffix).

### Limitations

* Each acronym definition must be on their own line with a blank line between them.

## Output

### HTML

```html
<p>You can use <abbr title="Cascading Style Sheets">CSS</abbr> to style your <abbr title="HyperText Markup Language">HTML</abbr>.</p>
```
