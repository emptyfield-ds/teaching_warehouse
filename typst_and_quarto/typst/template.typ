#let accent-color = rgb("#2c3e50")
#let soft-color = luma(100)
#let rule-color = luma(200)
#let sans-font = "Inter"

// 1. create a function called `cv()` that takes 5 arguments: `name: "", job_title: none, contact: (), summary: none, doc, `
// 2. put all the set and show rules from `typst/resume.typ` into the function body
// 3. return `doc` at the bottom of the function
// 4. in `typst/resume.typ`, import `cv` and `render-section`
// 5. in `typst/resume.typ`, replace the top section of the document (everything covered in `cv()`) with cv.with(...) (see `exercises.qmd` for the full code to insert)
____ = {
  // show and set rules
  ____

  align(center)[
    #block(above: 0pt, below: 12pt)[= #name]
    #if job_title != none {
      block(above: 0pt, below: 10pt)[
        #text(size: 11pt, style: "italic", fill: soft-color)[#job_title]
      ]
    }
    #if contact.len() > 0 {
      block(above: 0pt, below: 0pt)[
        #text(size: 9.5pt)[
          #contact.join[#h(0.6em) | #h(0.6em)]
        ]
      ]
    }
  ]

  v(1.3em)

  if summary != none {
    text(size: 10pt, style: "italic")[#summary]
  }

  // return the rest of the document content
  ___
}

#let render-section(title, entries) = {
  [== #title]
  v(-0.4em)
  line(length: 100%, stroke: 0.5pt + rule-color)
  v(0.2em)
  for (i, entry) in entries.enumerate() {
    grid(
      columns: (1fr, auto),
      text(weight: "bold", size: 10pt)[#entry.primary],
      text(fill: soft-color, size: 9.5pt)[#entry.dates],
    )
    grid(
      columns: (1fr, auto),
      text(style: "italic", size: 9.5pt)[#entry.secondary],
      text(fill: soft-color, size: 9pt)[#entry.location],
    )
    if "bullets" in entry and entry.bullets.len() > 0 {
      v(0.1em)
      for bullet in entry.bullets {
        block(inset: (left: 1em, top: 0.05em, bottom: 0.05em))[
          #text(size: 9.5pt)[- #bullet]
        ]
      }
    }
    if i < entries.len() - 1 {
      v(if "bullets" in entry { 0.5em } else { 0.3em })
    }
  }
}
