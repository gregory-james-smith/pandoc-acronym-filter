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
\usepackage[printonlyused,nohyperlinks]{acronym}

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
* The filter will add an acronym header above a list of acronym definitions at the end of the document.

* First use of acronym is long form with short form following in brackets. Following usages are in short form.
* Short forms can have an `s` suffix for plurality.

* If you add a title and the title is in the document, the acronyms will be listed under it. If it is not in the document they will be listed at the end.
* Acronyms are listed in alphabetical order.

```
pandoc-acronym-filter:
  title: "My acronyms"
```

#### Latex

* Acronyms will appear in long form the first instance and the following instances in short form.
* List of acronyms are in alphabetical order.
* Uses the `acronym` package.
* Adds the `acronym` package to the TEX preamble. This may cause errors if the `acronym` package is already added. Therefore there is no need to add the following to the Markdown metadata block:
``````
---
header-includes:
- |
  ```{=latex}
  \usepackage[printonlyused,nohyperlinks]{acronym}
  ```
---
``````
* Options can be sent to acronym package with the `options` metadata.
* A title can be given with the `title` metadata. If provided the acronyms are listed under that heading. The heading must already exist in the document.

```
pandoc-acronym-filter:
  options: [printonlyused]
  title: "My acronyms"
```

### Limitations

* Each acronym definition must be on their own line with a blank line between them.
* The filter will not match an acronym if it is followed by an ellipsis. The ellipsis is not recognised as punctuation by the pattern matching.
* Will not work for acronyms which are plural without `s` suffix, for example, Systems on a Chip (SOACs).
* Filter will only work for HTML and Latex (including PDF) outputs. Other outputs will only have the acronym definitions removed from the document.
* Filter will not match an acronym with preceding punctuation like an opening bracket, for example `(HTML)`.

## Options

Options passed in through the metadata block are sent to the `acronym` Latex package as options.

```
pandoc-acronym-filter:
  options: [printonlyused]
```

Unless otherwise stated, these options will have no impact on output other than Latex.

| Option | Latex `acronym` package | Other affects | Default |
|---|---|---|---|
| `footnote` | Makes the full name appear as a footnote when the acronym is first used. | None | No |
| `nohyperlinks` | If `hyperref` is loaded, all acronyms will link to their glossary entry. With the option `nohyperlinks` these links are suppressed. | None | Yes |
| `printonlyused` | Only list used acronyms. | None | Yes |
| `withpage` | Show the page number where each acronym was first used. Only works with `printonlyused` option. | None | No |
| `smaller` | Make the acronym appear smaller. | None | No |
| `dua` | “Don’t use acronyms”. Unless explicitly requested all acronyms are suppressed and the full name is given. | None | No |
| `nolist` | The option nolist stands for “don’t write the list of acronyms”. | Also removes acronym header so there is not a section without any acronyms. | No |
