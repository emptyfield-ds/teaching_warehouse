#let accent-color = rgb("#2c3e50")
#let soft-color = luma(100)
#let rule-color = luma(200)
#let sans-font = "Inter"

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

#let cv(
  name: "",
  job_title: none,
  contact: (),
  summary: none,
  doc,
) = {
  set page("us-letter", margin: (x: 2.2cm, y: 2cm), numbering: "1")
  set text(font: ("Libertinus Serif", "New Computer Modern"), size: 10.5pt, lang: "en")
  set par(justify: false, leading: 0.6em)
  show heading: set text(font: sans-font, size: 24pt, weight: "bold", fill: accent-color)

  show heading.where(level: 2): it => {
    v(0.8em)
    text(
      font: sans-font,
      size: 10.5pt,
      weight: "semibold",
      fill: accent-color,
      tracking: 1.5pt,
    )[#upper(it.body)]
  }

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

  doc
}
