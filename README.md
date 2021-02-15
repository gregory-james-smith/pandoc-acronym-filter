# Pandoc Acronym Filter

Pandoc Lua filter for transforming Markdown documents using MMD acronym syntax into HTML and Latex documents.

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

Outputs other than HTML and Latex (including PDF) will only have the acronym definitions removed from the document.

### HTML

```html
<p>You can use <abbr title="Cascading Style Sheets">CSS</abbr> to style your <abbr title="HyperText Markup Language">HTML</abbr>.</p>
```

### Latex

The first use of the acronym is in long form with short form following in brackets. Following usages are in short form.

The `acronym` package is used to handle the acronyms. The filter will add the package to the Latex document. This may cause errors if the `acronym` package is already included.

```latex
\usepackage[printonlyused,nohyperlinks]{acronym}

You can use \ac{CSS} to style your \ac{HTML}.

\begin{acronym}
    \acro{CSS}{Cascading Style Sheets}
    \acro{HTML}{Hyper Text Markup Language}
\end{acronym}
```

## Options

Options can be added using the Markdown meta data block.

```
pandoc-acronym-filter:
  options: [printonlyused]
```

These options only have an effect when generating Latex documents.

### Latex

These options are passed to the `acronym` Latex package as options and therefore have the same affect on the document. The `nolist` option has the addition affect of excluding the creation of any header for the list of acronyms. `nohyperlinks` and `printonlyused` are the default options if no options are provided.

| Option | Latex `acronym` package option |
|---|---|
| `footnote` | Makes the full name appear as a footnote when the acronym is first used. |
| `nohyperlinks` | If `hyperref` is loaded, all acronyms will link to their glossary entry. With the option `nohyperlinks` these links are suppressed. |
| `printonlyused` | Only list used acronyms. |
| `withpage` | Show the page number where each acronym was first used. Only works with `printonlyused` option. |
| `smaller` | Make the acronym appear smaller. |
| `dua` | “Don’t use acronyms”. Unless explicitly requested all acronyms are suppressed and the full name is given. |
| `nolist` | The option nolist stands for “don’t write the list of acronyms”. |

## Features

### List of acronyms

For Latex generated documents, all the acronyms are listed in the document so long as the `nolist` option is not included. The list of acronyms are in alphabetical order.

A title of the list of acronyms can be added using the Markdown meta data block.

```
pandoc-acronym-filter:
  title: "My acronyms"
```

If a no title is given then the list of acronyms is generated at the end of the document with the default section heading of "Acronyms".

If a title is given and there is a heading in the document that matches the title, then the list of acronyms are generated immediately after that heading. If no heading matching the title can be found, then the list of acronyms are generated at the end of the document with a section heading added matching the title provided.

### Pattern matching for acronyms

* The filter will match the acronym even if it is followed by punctuation.
* The filter will match the acronym even if it is an English plural (has an `s` suffix).
* The filter will not match an acronym if it is followed by an ellipsis. The ellipsis is not recognised as punctuation by the pattern matching.
* Filter will not match an acronym with preceding punctuation like an opening bracket, for example `(HTML)`.
* Will not work for acronyms which are plural without `s` suffix, for example, Systems on a Chip (SOACs).

### Acronym definitions

* Each acronym definition must be on their own line with a blank line between them.
