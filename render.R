
rmarkdown::render("README.Rmd",
                  output_format = "github_document",
                  output_options = list(
                    html_preview = FALSE,
                    toc = TRUE, 
                    toc_depth = 6)
)
