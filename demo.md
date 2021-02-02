---
title: Demonstration of `pandoc-acronym-filter`
header-includes: |
    \usepackage[printonlyused,nohyperlinks]{acronym}
---

# Demonstration

The HTML specification is maintained by the W3C. The use of abbreviations means that any use of the abbreviation, such as HTML or W3C is linked to the abbreviation.

*[HTML]: Hyper Text Markup Language

*[W3C]: World Wide Web Consortium

Websites **use HTTP to communicate** their contents with browsers.

*[HTTP]: Hyper Text Transfer Protocol

*[CSS]: Cascading Style Sheets

This is a sentence that includes *some* text formatting which should not be affected by the acronym definition. HTTP is often used in browsers.

# Plurals

I have a lot of old CDs.

*[CD]: Compact Disk

# Unmodified

```
Do not expect acronyms in code blocks, like this one HTML, to be modified.
```

> And acronyms in quotations, like this one W3C, should also not be modified.

# Acronyms
