library(fs)
library(coursedeployr)
library(tidyverse)
withr::with_dir("/Users/malcolmbarrett/Desktop/day_1_unsanitized/", {
  dir_ls() %>% walk(render_slides)
})

withr::with_dir("/Users/malcolmbarrett/Desktop/day_1_unsanitized/", {
  render_slides("r_packages_add_files")
})

fs::dir_copy(
  "/Users/malcolmbarrett/Desktop/day_1_unsanitized/",
  "/Users/malcolmbarrett/Desktop/day_1_unsanitized_bu/"
)

withr::with_dir("/Users/malcolmbarrett/Desktop/day_1_unsanitized/", {
  dir_ls() %>% walk(sanitize_module, new_path = "../day_1_sanitized/")
})
