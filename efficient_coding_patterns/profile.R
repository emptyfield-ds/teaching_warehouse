sum_squared_diffs <- function(mat) {
  col_means <- apply(mat, 2, mean)
  result <- numeric(ncol(mat))

  for (i in seq_len(ncol(mat))) {
    result[i] <- sum((mat[, i] - col_means[i])^2)
  }

  result
}

set.seed(42)
mat <- matrix(rnorm(1e6), nrow = 1000, ncol = 1000)

