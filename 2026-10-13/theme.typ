#import "@preview/touying:0.8.0": config-page, themes

#import themes.simple: simple-theme, slide

#let olive = rgb("646f3c")
#let cream = rgb("fffbe7")
#let ink = rgb("#000000")
#let ink2 = rgb("25291d")
#let orange = rgb("b05024")

#let apply-theme(entire-document) = {
  set text(font: "Inter", size: 16pt, fill: ink)
  show math.equation: set text(font: "New Computer Modern Math")
  entire-document
}

#let slide-title(title-string) = {
  // text(font: "Libertinus Serif", size: 38pt, fill: olive, title-string)
  heading(level: 2)[#text(font: "Libertinus Serif", weight: "bold", size: 38pt, fill: olive, title-string)]
}

#let section-slide(section-title-string) = {
  set par(leading: 0.4em)
  slide(config: config-page(fill: orange, footer: none))[#align(horizon, heading()[#text(
    font: "Libertinus Serif",
    weight: "regular",
    size: 72pt,
    fill: cream,
    section-title-string,
  )])]
}
