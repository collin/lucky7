class Lucky7::SpecBuilder < Lucky7::Builder
  SrcRegex       = /\/jass/
  BuildDirectory = ""

  builds Jass, :files => "#{Lucky7Root}/jspec/jass/**/*.html.jass"
end