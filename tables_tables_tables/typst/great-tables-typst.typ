// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#f1f3f5")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  place(
    top,
    float: true,
    scope: "parent",
    clearance: 4mm,
    block(below: 1em, width: 100%)[

      #if title != none {
        align(center, block(inset: 2em)[
          #set par(leading: heading-line-height) if heading-line-height != none
          #set text(font: heading-family) if heading-family != none
          #set text(weight: heading-weight)
          #set text(style: heading-style) if heading-style != "normal"
          #set text(fill: heading-color) if heading-color != black

          #text(size: title-size)[#title #if thanks != none {
            footnote(thanks, numbering: "*")
            counter(footnote).update(n => n - 1)
          }]
          #(if subtitle != none {
            parbreak()
            text(size: subtitle-size)[#subtitle]
          })
        ])
      }

      #if authors != none and authors != () {
        let count = authors.len()
        let ncols = calc.min(count, 3)
        grid(
          columns: (1fr,) * ncols,
          row-gutter: 1.5em,
          ..authors.map(author =>
              align(center)[
                #author.name \
                #author.affiliation \
                #author.email
              ]
          )
        )
      }

      #if date != none {
        align(center)[#block(inset: 1em)[
          #date
        ]]
      }

      #if abstract != none {
        block(inset: 2em)[
        #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
        ]
      }
    ]
  )

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  title: [Great Tables: Typst Rendering Examples],
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

#Skylighting(([#ImportTok("import");#NormalTok(" numpy ");#ImportTok("as");#NormalTok(" np");],
[#ImportTok("import");#NormalTok(" pandas ");#ImportTok("as");#NormalTok(" pd");],
[#ImportTok("from");#NormalTok(" great_tables ");#ImportTok("import");#NormalTok(" GT, md, typst, loc, style");],
[],
[#NormalTok("cohort_df ");#OperatorTok("=");#NormalTok(" pd.DataFrame(");],
[#NormalTok("    {");],
[#NormalTok("        ");#StringTok("\"Characteristic\"");#NormalTok(": [");],
[#NormalTok("            ");#StringTok("\"N\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"Age (mean)\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"Documented Sex Female (%)\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"Race/Ethnicity (%)\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("White\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("Black\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("Hispanic\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("Other\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"Region (%)\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("Northeast\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("Midwest\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("West\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("South\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"Stage at Diagnosis (%)\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("I/II\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("III\"");#NormalTok(",");],
[#NormalTok("            ");#StringTok("\"");#CharTok("\\u00a0\\u00a0\\u00a0");#StringTok("IV\"");#NormalTok(",");],
[#NormalTok("        ],");],
[#NormalTok("        ");#StringTok("\"dev_cohort\"");#NormalTok(": [");],
[#NormalTok("            ");#DecValTok("14760");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("72.1");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("45.4");#NormalTok(",");],
[#NormalTok("            np.nan,");],
[#NormalTok("            ");#FloatTok("82.7");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("8.8");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("4.2");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("4.2");#NormalTok(",");],
[#NormalTok("            np.nan,");],
[#NormalTok("            ");#FloatTok("20.3");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("13.6");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("34.2");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("31.9");#NormalTok(",");],
[#NormalTok("            np.nan,");],
[#NormalTok("            ");#FloatTok("15.1");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("34.0");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("50.8");#NormalTok(",");],
[#NormalTok("        ],");],
[#NormalTok("        ");#StringTok("\"val_cohort\"");#NormalTok(": [");],
[#NormalTok("            ");#DecValTok("14620");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("71.9");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("46.8");#NormalTok(",");],
[#NormalTok("            np.nan,");],
[#NormalTok("            ");#FloatTok("81.4");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("8.9");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("4.4");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("5.3");#NormalTok(",");],
[#NormalTok("            np.nan,");],
[#NormalTok("            ");#FloatTok("20.2");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("13.2");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("34.5");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("32.2");#NormalTok(",");],
[#NormalTok("            np.nan,");],
[#NormalTok("            ");#FloatTok("14.8");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("33.1");#NormalTok(",");],
[#NormalTok("            ");#FloatTok("52.0");#NormalTok(",");],
[#NormalTok("        ],");],
[#NormalTok("    }");],
[#NormalTok(")");],
[],
[#CommentTok("# Identify category header rows (have NaN values)");],
[#NormalTok("category_rows ");#OperatorTok("=");#NormalTok(" cohort_df[cohort_df[");#StringTok("\"dev_cohort\"");#NormalTok("].isna()].index.tolist()");],
[],
[#NormalTok("gt_cohort ");#OperatorTok("=");#NormalTok(" (");],
[#NormalTok("    GT(cohort_df)");],
[#NormalTok("    .cols_label(");],
[#NormalTok("        dev_cohort");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"*Development Cohort* ");#ErrorTok("\\");#StringTok(" 2010–2011 Diagnosis\"");#NormalTok("),");],
[#NormalTok("        val_cohort");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"*Validation Cohort* ");#ErrorTok("\\");#StringTok(" 2012–2013 Diagnosis\"");#NormalTok("),");],
[#NormalTok("    )");],
[#NormalTok("    .fmt_number(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"dev_cohort\"");#NormalTok(", ");#StringTok("\"val_cohort\"");#NormalTok("], decimals");#OperatorTok("=");#DecValTok("1");#NormalTok(")");],
[#NormalTok("    .fmt_integer(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"dev_cohort\"");#NormalTok(", ");#StringTok("\"val_cohort\"");#NormalTok("], rows");#OperatorTok("=");#NormalTok("[");#DecValTok("0");#NormalTok("], use_seps");#OperatorTok("=");#VariableTok("True");#NormalTok(")");],
[#NormalTok("    .sub_missing(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"dev_cohort\"");#NormalTok(", ");#StringTok("\"val_cohort\"");#NormalTok("], missing_text");#OperatorTok("=");#StringTok("\"\"");#NormalTok(")");],
[#NormalTok("    .cols_align(align");#OperatorTok("=");#StringTok("\"left\"");#NormalTok(", columns");#OperatorTok("=");#StringTok("\"Characteristic\"");#NormalTok(")");],
[#NormalTok("    .cols_align(align");#OperatorTok("=");#StringTok("\"right\"");#NormalTok(", columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"dev_cohort\"");#NormalTok(", ");#StringTok("\"val_cohort\"");#NormalTok("])");],
[#NormalTok("    .cols_width(");],
[#NormalTok("        {");#StringTok("\"Characteristic\"");#NormalTok(": ");#StringTok("\"200px\"");#NormalTok(", ");#StringTok("\"dev_cohort\"");#NormalTok(": ");#StringTok("\"160px\"");#NormalTok(", ");#StringTok("\"val_cohort\"");#NormalTok(": ");#StringTok("\"160px\"");#NormalTok("}");],
[#NormalTok("    )");],
[#NormalTok("    .tab_style(");],
[#NormalTok("        style");#OperatorTok("=");#NormalTok("style.text(weight");#OperatorTok("=");#StringTok("\"bold\"");#NormalTok("),");],
[#NormalTok("        locations");#OperatorTok("=");#NormalTok("loc.body(columns");#OperatorTok("=");#StringTok("\"Characteristic\"");#NormalTok(", rows");#OperatorTok("=");#NormalTok("category_rows),");],
[#NormalTok("    )");],
[#NormalTok("    .tab_options(");],
[#NormalTok("        column_labels_font_weight");#OperatorTok("=");#StringTok("\"bold\"");#NormalTok(",");],
[#NormalTok("    )");],
[#NormalTok(")");],
[],
[#NormalTok("gt_cohort");],));
#figure([
#set text(font: ("Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Helvetica Neue", "Fira Sans", "Droid Sans", "Arial", "sans-serif",))
#set text(fill: rgb("#333333"))
#table(
  columns: (150pt, 120pt, 120pt,),
  align: (left, right, right,),
  stroke: (x: none, y: 0.75pt + rgb("#D3D3D3")),
  inset: (x: 3.75pt, y: 6pt),
  table.hline(stroke: 1.5pt + rgb("#A8A8A8")),
  table.header(
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  [*Characteristic*], [**Development Cohort* \ 2010–2011 Diagnosis*], [**Validation Cohort* \ 2012–2013 Diagnosis*],
  ),
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  [N], [14,760], [14,620],
  [Age (mean)], [72.1], [71.9],
  [Documented Sex Female (%)], [45.4], [46.8],
  [#text(weight: "bold")[Race/Ethnicity (%)]], [], [],
  [   White], [82.7], [81.4],
  [   Black], [8.8], [8.9],
  [   Hispanic], [4.2], [4.4],
  [   Other], [4.2], [5.3],
  [#text(weight: "bold")[Region (%)]], [], [],
  [   Northeast], [20.3], [20.2],
  [   Midwest], [13.6], [13.2],
  [   West], [34.2], [34.5],
  [   South], [31.9], [32.2],
  [#text(weight: "bold")[Stage at Diagnosis (%)]], [], [],
  [   I/II], [15.1], [14.8],
  [   III], [34.0], [33.1],
  [   IV], [50.8], [52.0],
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  table.hline(stroke: 1.5pt + rgb("#A8A8A8")),
)
], caption: figure.caption(
position: top, 
[
Cohort summary statistics.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-cohort>


#Skylighting(([#NormalTok("perf_df ");#OperatorTok("=");#NormalTok(" pd.DataFrame({");],
[#NormalTok("    ");#StringTok("\"Method\"");#NormalTok(": [");],
[#NormalTok("        ");#StringTok("\"Baseline\"");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Group ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("1");#DecValTok("$");#VerbatimStringTok(" ");#CharTok("\\ ");#VerbatimStringTok("Pop ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("1, 0");#DecValTok(".");#VerbatimStringTok("2");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Max ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("1");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Group ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("2, 0");#DecValTok(".");#VerbatimStringTok("3");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Max ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("2, 0");#DecValTok(".");#VerbatimStringTok("3, 0");#DecValTok(".");#VerbatimStringTok("4, 0");#DecValTok(".");#VerbatimStringTok("5, 0");#DecValTok(".");#VerbatimStringTok("6");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Group ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("4, 0");#DecValTok(".");#VerbatimStringTok("5, 0");#DecValTok(".");#VerbatimStringTok("6, 0");#DecValTok(".");#VerbatimStringTok("7,");#DecValTok("$");#VerbatimStringTok(" ");#CharTok("\\ ");#VerbatimStringTok("#context h");#KeywordTok("(");#VerbatimStringTok("measure");#KeywordTok("(");#PreprocessorTok("[Group $alpha =$]");#KeywordTok(")");#DecValTok(".");#VerbatimStringTok("width ");#OperatorTok("+");#VerbatimStringTok(" 0");#DecValTok(".");#VerbatimStringTok("3em");#KeywordTok(")");#VerbatimStringTok(" ");#DecValTok("$");#VerbatimStringTok("0");#DecValTok(".");#VerbatimStringTok("8, 0");#DecValTok(".");#VerbatimStringTok("9, 0");#DecValTok(".");#VerbatimStringTok("99");#DecValTok("$");#VerbatimStringTok(" ");#CharTok("\\ ");#VerbatimStringTok("Pop ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("3, 0");#DecValTok(".");#VerbatimStringTok("4, 0");#DecValTok(".");#VerbatimStringTok("5, 0");#DecValTok(".");#VerbatimStringTok("6,");#DecValTok("$");#VerbatimStringTok(" ");#CharTok("\\ ");#VerbatimStringTok("#context h");#KeywordTok("(");#VerbatimStringTok("measure");#KeywordTok("(");#PreprocessorTok("[Pop $alpha =$]");#KeywordTok(")");#DecValTok(".");#VerbatimStringTok("width ");#OperatorTok("+");#VerbatimStringTok(" 0");#DecValTok(".");#VerbatimStringTok("3em");#KeywordTok(")");#VerbatimStringTok(" ");#DecValTok("$");#VerbatimStringTok("0");#DecValTok(".");#VerbatimStringTok("7, 0");#DecValTok(".");#VerbatimStringTok("8, 0");#DecValTok(".");#VerbatimStringTok("9, 0");#DecValTok(".");#VerbatimStringTok("99");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Max ");#DecValTok("$");#VerbatimStringTok("alpha = 0");#DecValTok(".");#VerbatimStringTok("7, 0");#DecValTok(".");#VerbatimStringTok("8, 0");#DecValTok(".");#VerbatimStringTok("9, 0");#DecValTok(".");#VerbatimStringTok("99");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'ExpGrad, Ep ");#DecValTok("$");#VerbatimStringTok("= 0");#DecValTok(".");#VerbatimStringTok("1");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'ExpGrad, Ep ");#DecValTok("$");#VerbatimStringTok("= 0");#DecValTok(".");#VerbatimStringTok("01");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Grid, CW ");#DecValTok("$");#VerbatimStringTok("= 0");#DecValTok(".");#VerbatimStringTok("25");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Grid, CW ");#DecValTok("$");#VerbatimStringTok("= 0");#DecValTok(".");#VerbatimStringTok("5");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r'Grid, CW ");#DecValTok("$");#VerbatimStringTok("= 0");#DecValTok(".");#VerbatimStringTok("75");#DecValTok("$");#VerbatimStringTok("'");#NormalTok(",");],
[#NormalTok("    ],");],
[#NormalTok("    ");#StringTok("\"Accuracy\"");#NormalTok(": [");#FloatTok("0.95");#NormalTok(", ");#FloatTok("0.95");#NormalTok(", ");#FloatTok("0.95");#NormalTok(", ");#FloatTok("0.93");#NormalTok(", ");#FloatTok("0.94");#NormalTok(", ");#FloatTok("0.92");#NormalTok(", ");#FloatTok("0.91");#NormalTok(", ");#FloatTok("0.96");#NormalTok(", ");#FloatTok("0.93");#NormalTok(", ");#FloatTok("0.32");#NormalTok(", ");#FloatTok("0.11");#NormalTok(", ");#FloatTok("0.11");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"Sensitivity\"");#NormalTok(": [");#FloatTok("0.36");#NormalTok(", ");#FloatTok("0.37");#NormalTok(", ");#FloatTok("0.29");#NormalTok(", ");#FloatTok("0.38");#NormalTok(", ");#FloatTok("0.31");#NormalTok(", ");#FloatTok("0.39");#NormalTok(", ");#FloatTok("0.33");#NormalTok(", ");#FloatTok("0.15");#NormalTok(", ");#FloatTok("0.13");#NormalTok(", ");#FloatTok("0.90");#NormalTok(", ");#FloatTok("0.95");#NormalTok(", ");#FloatTok("0.95");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"Mean\"");#NormalTok(": [");#FloatTok("0.09");#NormalTok(", ");#FloatTok("0.02");#NormalTok(", ");#FloatTok("0.08");#NormalTok(", ");#FloatTok("0.03");#NormalTok(", ");#FloatTok("0.08");#NormalTok(", ");#FloatTok("0.02");#NormalTok(", ");#FloatTok("0.08");#NormalTok(", ");#FloatTok("0.04");#NormalTok(", ");#FloatTok("0.02");#NormalTok(", ");#FloatTok("0.01");#NormalTok(", ");#FloatTok("0.01");#NormalTok(", ");#FloatTok("0.01");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"Black\"");#NormalTok(": [");#FloatTok("0.06");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.06");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.07");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.08");#NormalTok(", ");#FloatTok("0.03");#NormalTok(", ");#FloatTok("0.01");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.02");#NormalTok(", ");#FloatTok("0.02");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"Asian\"");#NormalTok(": [");#FloatTok("0.24");#NormalTok(", ");#FloatTok("0.19");#NormalTok(", ");#FloatTok("0.17");#NormalTok(", ");#FloatTok("0.23");#NormalTok(", ");#FloatTok("0.11");#NormalTok(", ");#FloatTok("0.17");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.12");#NormalTok(", ");#FloatTok("0.10");#NormalTok(", ");#FloatTok("0.12");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.00");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"HNW\"");#NormalTok(": [");#FloatTok("0.07");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.07");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.08");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.13");#NormalTok(", ");#FloatTok("0.02");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.00");#NormalTok(", ");#FloatTok("0.00");#NormalTok("],");],
[#NormalTok("})");],
[],
[#NormalTok("(");],
[#NormalTok("    GT(perf_df)");],
[#NormalTok("    .fmt_typst(columns");#OperatorTok("=");#StringTok("\"Method\"");#NormalTok(")");],
[#NormalTok("    .fmt_number(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"Accuracy\"");#NormalTok(", ");#StringTok("\"Sensitivity\"");#NormalTok(", ");#StringTok("\"Mean\"");#NormalTok(", ");#StringTok("\"Black\"");#NormalTok(", ");#StringTok("\"Asian\"");#NormalTok(", ");#StringTok("\"HNW\"");#NormalTok("], decimals");#OperatorTok("=");#DecValTok("2");#NormalTok(")");],
[#NormalTok("    .tab_spanner(label");#OperatorTok("=");#StringTok("\"Unfairness\"");#NormalTok(", columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"Mean\"");#NormalTok(", ");#StringTok("\"Black\"");#NormalTok(", ");#StringTok("\"Asian\"");#NormalTok(", ");#StringTok("\"HNW\"");#NormalTok("])");],
[#NormalTok("    .cols_align(align");#OperatorTok("=");#StringTok("\"left\"");#NormalTok(", columns");#OperatorTok("=");#StringTok("\"Method\"");#NormalTok(")");],
[#NormalTok("    .cols_align(align");#OperatorTok("=");#StringTok("\"center\"");#NormalTok(", columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"Accuracy\"");#NormalTok(", ");#StringTok("\"Sensitivity\"");#NormalTok(", ");#StringTok("\"Mean\"");#NormalTok(", ");#StringTok("\"Black\"");#NormalTok(", ");#StringTok("\"Asian\"");#NormalTok(", ");#StringTok("\"HNW\"");#NormalTok("])");],
[#NormalTok("    .cols_width({");#StringTok("\"Method\"");#NormalTok(": ");#StringTok("\"200px\"");#NormalTok("})");],
[#NormalTok("    .tab_source_note(");],
[#NormalTok("        typst(");],
[#NormalTok("            ");#StringTok("\"*Note:* Novel fair penalized regressions were defined based on the \"");],
[#NormalTok("            ");#StringTok("\"multi-group unfairness synthesis mechanism: population-weighted average \"");],
[#NormalTok("            ");#StringTok("\"(Pop), group-weighted average (Group), and maximum (Max) as well as \"");],
[#NormalTok("            ");#StringTok("\"fairness score weight ($alpha$). Fair reductions comparisons were \"");],
[#NormalTok("            ");#StringTok("\"exponentiated gradient (ExpGrad) or grid search (Grid) methods, varying \"");],
[#NormalTok("            ");#StringTok("\"constraint flexibility (Ep) or constraint weight (CW), respectively. \"");],
[#NormalTok("            ");#StringTok("\"'HNW' is Hispanic non-white.\"");],
[#NormalTok("        )");],
[#NormalTok("    )");],
[#NormalTok("    .tab_options(column_labels_font_weight");#OperatorTok("=");#StringTok("\"bold\"");#NormalTok(")");],
[#NormalTok(")");],));
#figure([
#set text(font: ("Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Helvetica Neue", "Fira Sans", "Droid Sans", "Arial", "sans-serif",))
#set text(fill: rgb("#333333"))
#table(
  columns: (150pt, auto, auto, auto, auto, auto, auto,),
  align: (left, center, center, center, center, center, center,),
  stroke: (x: none, y: 0.75pt + rgb("#D3D3D3")),
  inset: (x: 3.75pt, y: 6pt),
  table.hline(stroke: 1.5pt + rgb("#A8A8A8")),
  table.header(
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  [], [], [], table.cell(colspan: 4, align: center)[*Unfairness*],
  table.hline(start: 3, end: 7, stroke: 0.75pt + rgb("#D3D3D3")),
  [*Method*], [*Accuracy*], [*Sensitivity*], [*Mean*], [*Black*], [*Asian*], [*HNW*],
  ),
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  [Baseline], [0.95], [0.36], [0.09], [0.06], [0.24], [0.07],
  [Group $alpha = 0.1$ \ Pop $alpha = 0.1, 0.2$], [0.95], [0.37], [0.02], [0.00], [0.19], [0.00],
  [Max $alpha = 0.1$], [0.95], [0.29], [0.08], [0.06], [0.17], [0.07],
  [Group $alpha = 0.2, 0.3$], [0.93], [0.38], [0.03], [0.00], [0.23], [0.00],
  [Max $alpha = 0.2, 0.3, 0.4, 0.5, 0.6$], [0.94], [0.31], [0.08], [0.07], [0.11], [0.08],
  [Group $alpha = 0.4, 0.5, 0.6, 0.7,$ \ #context h(measure([Group $alpha =$]).width + 0.3em) $0.8, 0.9, 0.99$ \ Pop $alpha = 0.3, 0.4, 0.5, 0.6,$ \ #context h(measure([Pop $alpha =$]).width + 0.3em) $0.7, 0.8, 0.9, 0.99$], [0.92], [0.39], [0.02], [0.00], [0.17], [0.00],
  [Max $alpha = 0.7, 0.8, 0.9, 0.99$], [0.91], [0.33], [0.08], [0.08], [0.00], [0.13],
  [ExpGrad, Ep $= 0.1$], [0.96], [0.15], [0.04], [0.03], [0.12], [0.02],
  [ExpGrad, Ep $= 0.01$], [0.93], [0.13], [0.02], [0.01], [0.10], [0.00],
  [Grid, CW $= 0.25$], [0.32], [0.90], [0.01], [0.00], [0.12], [0.00],
  [Grid, CW $= 0.5$], [0.11], [0.95], [0.01], [0.02], [0.00], [0.00],
  [Grid, CW $= 0.75$], [0.11], [0.95], [0.01], [0.02], [0.00], [0.00],
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  table.cell(colspan: 7, align: left, fill: rgb("#FFFFFF"), inset: (x: 3.75pt, y: 3pt))[#text(size: 0.90em)[*Note:* Novel fair penalized regressions were defined based on the multi-group unfairness synthesis mechanism: population-weighted average (Pop), group-weighted average (Group), and maximum (Max) as well as fairness score weight ($alpha$). Fair reductions comparisons were exponentiated gradient (ExpGrad) or grid search (Grid) methods, varying constraint flexibility (Ep) or constraint weight (CW), respectively. 'HNW' is Hispanic non-white.]],
  table.hline(stroke: 1.5pt + rgb("#A8A8A8")),
)
], caption: figure.caption(
position: top, 
[
#strong[Performance for Baseline Unpenalized Regression, Novel Penalized Regressions, and Fair Reductions Methods.]
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-performance>


#Skylighting(([#NormalTok("reg_df ");#OperatorTok("=");#NormalTok(" pd.DataFrame({");],
[#NormalTok("    ");#StringTok("\"Method\"");#NormalTok(": [");],
[#NormalTok("        ");#StringTok("\"Average\"");#NormalTok(",");],
[#NormalTok("        ");#StringTok("\"Covariance\"");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r\"Net Compensation#super");#PreprocessorTok("[$dagger$]");#VerbatimStringTok("\"");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r\"Weighted Average#super");#PreprocessorTok("[$dagger.double$]");#VerbatimStringTok("\"");#NormalTok(",");],
[#NormalTok("        ");#VerbatimStringTok("r\"Mean Residual ");#CharTok("\\ ");#VerbatimStringTok("Difference#super");#PreprocessorTok("[$plus.circle$]");#VerbatimStringTok("\"");#NormalTok(",");],
[#NormalTok("        ");#StringTok("\"OLS\"");#NormalTok(",");],
[#NormalTok("    ],");],
[#NormalTok("    ");#StringTok("\"r2\"");#NormalTok(": [");#FloatTok("12.4");#NormalTok(", ");#FloatTok("12.4");#NormalTok(", ");#FloatTok("12.5");#NormalTok(", ");#FloatTok("12.6");#NormalTok(", ");#FloatTok("12.8");#NormalTok(", ");#FloatTok("12.9");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"ratio_g\"");#NormalTok(": [");#FloatTok("0.996");#NormalTok(", ");#FloatTok("0.996");#NormalTok(", ");#FloatTok("0.980");#NormalTok(", ");#FloatTok("0.964");#NormalTok(", ");#FloatTok("0.895");#NormalTok(", ");#FloatTok("0.837");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"ratio_gc\"");#NormalTok(": [");#FloatTok("1.001");#NormalTok(", ");#FloatTok("1.001");#NormalTok(", ");#FloatTok("1.006");#NormalTok(", ");#FloatTok("1.011");#NormalTok(", ");#FloatTok("1.032");#NormalTok(", ");#FloatTok("1.050");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"comp_g\"");#NormalTok(": [");#OperatorTok("-");#DecValTok("46");#NormalTok(", ");#OperatorTok("-");#DecValTok("46");#NormalTok(", ");#OperatorTok("-");#DecValTok("232");#NormalTok(", ");#OperatorTok("-");#DecValTok("411");#NormalTok(", ");#OperatorTok("-");#DecValTok("1208");#NormalTok(", ");#OperatorTok("-");#DecValTok("1872");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"comp_gc\"");#NormalTok(": [");#DecValTok("4");#NormalTok(", ");#DecValTok("4");#NormalTok(", ");#DecValTok("34");#NormalTok(", ");#DecValTok("62");#NormalTok(", ");#DecValTok("188");#NormalTok(", ");#DecValTok("293");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"mrd\"");#NormalTok(": [");#OperatorTok("-");#DecValTok("50");#NormalTok(", ");#OperatorTok("-");#DecValTok("50");#NormalTok(", ");#OperatorTok("-");#DecValTok("266");#NormalTok(", ");#OperatorTok("-");#DecValTok("473");#NormalTok(", ");#OperatorTok("-");#DecValTok("1396");#NormalTok(", ");#OperatorTok("-");#DecValTok("2165");#NormalTok("],");],
[#NormalTok("    ");#StringTok("\"fair_cov\"");#NormalTok(": [");#DecValTok("6");#NormalTok(", ");#DecValTok("6");#NormalTok(", ");#DecValTok("31");#NormalTok(", ");#DecValTok("56");#NormalTok(", ");#DecValTok("164");#NormalTok(", ");#DecValTok("256");#NormalTok("],");],
[#NormalTok("})");],
[],
[#NormalTok("(");],
[#NormalTok("    GT(reg_df)");],
[#NormalTok("    .fmt_typst(columns");#OperatorTok("=");#StringTok("\"Method\"");#NormalTok(")");],
[#NormalTok("    .fmt_percent(columns");#OperatorTok("=");#StringTok("\"r2\"");#NormalTok(", decimals");#OperatorTok("=");#DecValTok("1");#NormalTok(", scale_values");#OperatorTok("=");#VariableTok("False");#NormalTok(", rows");#OperatorTok("=");#NormalTok("[");#DecValTok("0");#NormalTok("])");],
[#NormalTok("    .fmt_number(columns");#OperatorTok("=");#StringTok("\"r2\"");#NormalTok(", decimals");#OperatorTok("=");#DecValTok("1");#NormalTok(", rows");#OperatorTok("=");#NormalTok("[");#DecValTok("1");#NormalTok(", ");#DecValTok("2");#NormalTok(", ");#DecValTok("3");#NormalTok(", ");#DecValTok("4");#NormalTok(", ");#DecValTok("5");#NormalTok("])");],
[#NormalTok("    .fmt_number(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"ratio_g\"");#NormalTok(", ");#StringTok("\"ratio_gc\"");#NormalTok("], decimals");#OperatorTok("=");#DecValTok("3");#NormalTok(")");],
[#NormalTok("    .fmt_currency(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"comp_g\"");#NormalTok(", ");#StringTok("\"comp_gc\"");#NormalTok(", ");#StringTok("\"mrd\"");#NormalTok("], rows");#OperatorTok("=");#NormalTok("[");#DecValTok("0");#NormalTok("], decimals");#OperatorTok("=");#DecValTok("0");#NormalTok(")");],
[#NormalTok("    .fmt_integer(columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"comp_g\"");#NormalTok(", ");#StringTok("\"comp_gc\"");#NormalTok(", ");#StringTok("\"mrd\"");#NormalTok("], rows");#OperatorTok("=");#NormalTok("[");#DecValTok("1");#NormalTok(", ");#DecValTok("2");#NormalTok(", ");#DecValTok("3");#NormalTok(", ");#DecValTok("4");#NormalTok(", ");#DecValTok("5");#NormalTok("])");],
[#NormalTok("    .fmt_integer(columns");#OperatorTok("=");#StringTok("\"fair_cov\"");#NormalTok(")");],
[#NormalTok("    .cols_label(");],
[#NormalTok("        Method");#OperatorTok("=");#StringTok("\"Method\"");#NormalTok(",");],
[#NormalTok("        r2");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"$R^2$\"");#NormalTok("),");],
[#NormalTok("        ratio_g");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"$g$\"");#NormalTok("),");],
[#NormalTok("        ratio_gc");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"$g^c$\"");#NormalTok("),");],
[#NormalTok("        comp_g");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"$g$\"");#NormalTok("),");],
[#NormalTok("        comp_gc");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"$g^c$\"");#NormalTok("),");],
[#NormalTok("        mrd");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"Mean ");#ErrorTok("\\");#StringTok(" Residual ");#ErrorTok("\\");#StringTok(" Difference\"");#NormalTok("),");],
[#NormalTok("        fair_cov");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"Fair ");#ErrorTok("\\");#StringTok(" Covariance\"");#NormalTok("),");],
[#NormalTok("    )");],
[#NormalTok("    .tab_spanner(label");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"Predictive ");#ErrorTok("\\");#StringTok(" Ratio\"");#NormalTok("), columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"ratio_g\"");#NormalTok(", ");#StringTok("\"ratio_gc\"");#NormalTok("])");],
[#NormalTok("    .tab_spanner(label");#OperatorTok("=");#NormalTok("typst(");#StringTok("\"Net ");#ErrorTok("\\");#StringTok(" Compensation\"");#NormalTok("), columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"comp_g\"");#NormalTok(", ");#StringTok("\"comp_gc\"");#NormalTok("])");],
[#NormalTok("    .cols_align(align");#OperatorTok("=");#StringTok("\"center\"");#NormalTok(", columns");#OperatorTok("=");#NormalTok("[");#StringTok("\"r2\"");#NormalTok(", ");#StringTok("\"ratio_g\"");#NormalTok(", ");#StringTok("\"ratio_gc\"");#NormalTok(", ");#StringTok("\"comp_g\"");#NormalTok(", ");#StringTok("\"comp_gc\"");#NormalTok(", ");#StringTok("\"mrd\"");#NormalTok(", ");#StringTok("\"fair_cov\"");#NormalTok("])");],
[#NormalTok("    .cols_align(align");#OperatorTok("=");#StringTok("\"right\"");#NormalTok(", columns");#OperatorTok("=");#StringTok("\"Method\"");#NormalTok(")");],
[#NormalTok("    .tab_source_note(");],
[#NormalTok("        typst(");],
[#NormalTok("            ");#VerbatimStringTok("r'");#DecValTok("$");#VerbatimStringTok("dagger lambda = 10000");#DecValTok("$");#VerbatimStringTok(", ");#DecValTok("$");#VerbatimStringTok("dagger");#DecValTok(".");#VerbatimStringTok("double alpha = 0");#DecValTok(".");#VerbatimStringTok("2");#DecValTok("$");#VerbatimStringTok(", ");#DecValTok("$");#VerbatimStringTok("plus");#DecValTok(".");#VerbatimStringTok("circle lambda = 30000");#DecValTok("$");#VerbatimStringTok(" ");#CharTok("\\ ");#VerbatimStringTok("'");],
[#NormalTok("            ");#VerbatimStringTok("r\"_Note:_ Measures calculated based on cross-validated predicted values and \"");],
[#NormalTok("            ");#VerbatimStringTok("r\"sorted on net compensation");#DecValTok(".");#VerbatimStringTok(" Best performing hyperparameters for each \"");],
[#NormalTok("            ");#VerbatimStringTok("r\"estimator ");#KeywordTok("(");#VerbatimStringTok("with respect to fairness measures");#KeywordTok(")");#VerbatimStringTok(" are displayed");#DecValTok(".");#VerbatimStringTok(" Performance \"");],
[#NormalTok("            ");#VerbatimStringTok("r\"for covariance method was the same for all ");#DecValTok("$");#VerbatimStringTok("m");#DecValTok("$.");#VerbatimStringTok(" ");#DecValTok("$");#VerbatimStringTok("g");#DecValTok("^");#VerbatimStringTok("c");#DecValTok("$");#VerbatimStringTok(" is the complement of g");#DecValTok(".");#VerbatimStringTok("\"");],
[#NormalTok("        )");],
[#NormalTok("    )");],
[#NormalTok("    .tab_options(");],
[#NormalTok("        column_labels_font_weight");#OperatorTok("=");#StringTok("\"bold\"");#NormalTok(",");],
[#NormalTok("        table_body_hlines_style");#OperatorTok("=");#StringTok("\"none\"");#NormalTok(",");],
[#NormalTok("    )");],
[#NormalTok(")");],));
#figure([
#set text(font: ("Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Helvetica Neue", "Fira Sans", "Droid Sans", "Arial", "sans-serif",))
#set text(fill: rgb("#333333"))
#table(
  columns: 8,
  align: (right, center, center, center, center, center, center, center,),
  stroke: none,
  inset: (x: 3.75pt, y: 6pt),
  table.hline(stroke: 1.5pt + rgb("#A8A8A8")),
  table.header(
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  [], [], table.cell(colspan: 2, align: center)[*Predictive \ Ratio*], table.cell(colspan: 2, align: center)[*Net \ Compensation*], [], [],
  table.hline(start: 2, end: 4, stroke: 0.75pt + rgb("#D3D3D3")),
  table.hline(start: 4, end: 6, stroke: 0.75pt + rgb("#D3D3D3")),
  [*Method*], [*$R^2$*], [*$g$*], [*$g^c$*], [*$g$*], [*$g^c$*], [*Mean \ Residual \ Difference*], [*Fair \ Covariance*],
  ),
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  [Average], [12.4%], [0.996], [1.001], [-\$46], [\$4], [-\$50], [6],
  [Covariance], [12.4], [0.996], [1.001], [-46], [4], [-50], [6],
  [Net Compensation#super[$dagger$]], [12.5], [0.980], [1.006], [-232], [34], [-266], [31],
  [Weighted Average#super[$dagger.double$]], [12.6], [0.964], [1.011], [-411], [62], [-473], [56],
  [Mean Residual \ Difference#super[$plus.circle$]], [12.8], [0.895], [1.032], [-1,208], [188], [-1,396], [164],
  [OLS], [12.9], [0.837], [1.050], [-1,872], [293], [-2,165], [256],
  table.hline(stroke: 1.5pt + rgb("#D3D3D3")),
  table.cell(colspan: 8, align: left, fill: rgb("#FFFFFF"), inset: (x: 3.75pt, y: 3pt))[#text(size: 0.90em)[$dagger lambda = 10000$, $dagger.double alpha = 0.2$, $plus.circle lambda = 30000$ \ _Note:_ Measures calculated based on cross-validated predicted values and sorted on net compensation. Best performing hyperparameters for each estimator (with respect to fairness measures) are displayed. Performance for covariance method was the same for all $m$. $g^c$ is the complement of g.]],
  table.hline(stroke: 1.5pt + rgb("#A8A8A8")),
)
], caption: figure.caption(
position: top, 
[
Performance of Constrained and Penalized Regression Methods
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-regression>





