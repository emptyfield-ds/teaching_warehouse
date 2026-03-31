$-- This file connects the YAML front matter in the .qmd to the cv() function
$-- in typst-template.typ. It uses Pandoc template syntax ($if$, $for$, etc.) (include `$--` for comments)
$-- to conditionally pass each metadata field as a named argument.
$--
$-- Quarto processes this file *before Typst compilation, replacing $...$
$-- variables with values from the YAML front matter. The result is a plain
$-- Typst #show rule that applies the cv() template to the document.
$-- See https://pandoc.org/MANUAL.html#templates for more

#show: cv.with(
$-- if the `name` field exists in the yaml, populate it into the `name` argument of `cv.with()`
$if(name)$
  name: "$name$",
$endif$
$if(job_title)$
  job_title: "$job_title$",
$endif$
$-- Each contact item has a `text` field and an optional `url` field.
$-- Items with a url become clickable links; others render as plain text.
$if(contact)$
  contact: (
$for(contact)$
$if(it.url)$
    link("$it.url$")[$it.text$],
$else$
    [$it.text$],
$endif$
$endfor$
  ),
$endif$
$if(summary)$
  summary: [$summary$],
$endif$
)
