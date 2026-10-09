#import "@preview/touying:0.8.0": config-page, themes

#import themes.simple: simple-theme, slide

#let olive = rgb("646f3c")
#let cream = rgb("fffbe7")
#let ink = rgb("#000000")
#let ink2 = rgb("25291d")
#let orange = rgb("b05024")
#let slide-margin = 36pt
#let page-number-size = 8pt
#let page-number-fill = orange

#let apply-theme(entire-document, text-size: 14pt, math-size: 20pt) = {
  set text(font: "Inter", size: text-size, fill: ink)
  show math.equation: set text(font: "New Computer Modern Math", size: math-size)
  entire-document
}

#let slide-title(title-string, color: olive, font-size: 38pt) = {
  // text(font: "Libertinus Serif", size: 38pt, fill: olive, title-string)
  heading(level: 2)[#text(font: "Libertinus Serif", weight: "bold", size: font-size, fill: color, title-string)]
}

#let section-slide(section-title-string, color: cream, font-size: 72pt) = {
  set par(leading: 0.4em)
  slide(config: config-page(fill: orange, footer: none))[#align(horizon, heading()[#text(
    font: "Libertinus Serif",
    weight: "regular",
    size: font-size,
    fill: color,
    section-title-string,
  )])]
}

#let split-slide(left_percentage, left-body, right-body) = slide(
  config: config-page(margin: 0pt, footer: context place(bottom + right, dx: -slide-margin, dy: -20pt)[#text(
    size: page-number-size,
    fill: page-number-fill,
  )[#counter(page).display() / #counter(page).final().first()]]),
)[
  #grid(
    columns: (left_percentage, auto),
    block(
      width: 100%,
      height: 100%,
      fill: olive,
      inset: slide-margin,
    )[
      #set text(fill: cream)
      #left-body
    ],
    block(
      width: 100%,
      height: 100%,
      fill: cream,
      inset: slide-margin,
    )[
      #set text(fill: ink)
      #right-body
    ],
  )
]
