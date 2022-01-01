test_that("donations table is correct", {
  x <- gt_donations(donations_test_data)

  expect_s3_class(x, "gt_tbl")
})
