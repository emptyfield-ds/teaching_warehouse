test_that("label wrapping works", {
  library(ggplot2)

  x <- labs_wrap(
    title = "Here is my really long title. You see, I have a lot to say, you see.",
    width = 30
  )

  p <- ggplot(mtcars, aes(mpg, hp)) + x
  expect_s3_class(x, "labels")
  expect_s3_class(p, "ggplot")
  expect_equal(stringr::str_count(x$title, "\n"), 2)
  # we could also use vdiffr to take a snapshot of our plot:
  # vdiffr::expect_doppelganger(p)
})
