library(data.table)

# parse command line arguments to set the parameters of the simulation
# these are the default values
sims <- 10000
subjects <- 1000
gamma <- 1.0
out_file <- "results.csv"

# manually parse cli interface
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  for (i in seq(1, length(args), by = 2)) {
    flag <- args[i]
    val <- args[i + 1]

    if (flag == "--sims") {
      sims <- as.integer(val)
    }
    if (flag == "--subjects") {
      subjects <- as.integer(val)
    }
    if (flag == "--gamma") {
      gamma <- as.numeric(val)
    }
    if (flag == "--out") out_file <- val
  }
}

# configure number of cores based on what we requested
threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
setDTthreads(threads)

total_rows <- sims * subjects
dt <- data.table(
  sim_id = rep(1:sims, each = subjects),
  x = rnorm(total_rows, mean = 0, sd = 1)
)

# gamma controls the overlap. Higher Gamma = Less Overlap.
dt[, prop_score := 1 / (1 + exp(-(gamma * x)))]
dt[, treatment := runif(.N) < prop_score]

# True ATE = 2.0
dt[, y := 2 * treatment + x + rnorm(.N)]

results <- dt[,
  .(
    # IPW Estimator
    ipw_estimate = mean(
      (y * treatment) / prop_score - (y * (1 - treatment)) / (1 - prop_score)
    ),

    # Track max weight to diagnose positivity violations
    max_weight = max(1 / prop_score, 1 / (1 - prop_score))
  ),
  by = sim_id
]

output_dir <- dirname(out_file)
if (output_dir != "." && !dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

fwrite(results, out_file)
