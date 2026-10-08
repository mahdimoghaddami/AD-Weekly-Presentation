#let olive = rgb("646f3c")
#let cream = rgb("fffbe7")
#let ink = rgb("25291d")

#let apply-theme(entire-document) = {
  set text(font: "Libertinus Serif", size: 16pt, fill: ink)
  show math.equation: set text(font: "New Computer Modern Math")
  entire-document
}

#let title(title-string) = text(font: "Libertinus Serif", size: 38pt, fill: olive, title-string)
