library(parallel)

# parse command line arguments to set the parameters of the simulation
args <- commandArgs(trailingOnly = TRUE)
task_id <- as.numeric(args[1])
cpus_requested <- as.numeric(args[2])

total_patients <- 100000
dose_efficacy <- task_id * 0.1
patients_per_core <- floor(total_patients / cpus_requested)

simulate_batch <- function(core_id) {
  # Construct unique seed from task_id and core_id
  set.seed((task_id * 1000) + core_id)

  local_total_age <- 0
  local_deaths <- 0

  for (i in seq_len(patients_per_core)) {
    age <- 0
    alive <- TRUE

    while (alive && age < 100) {
      risk <- (0.01 + (0.001 * age)) * (1.0 - dose_efficacy)

      if (runif(1) < risk) {
        alive <- FALSE
        local_deaths <- local_deaths + 1
      } else {
        age <- age + 1
      }
    }
    local_total_age <- local_total_age + age
  }

  c(age = local_total_age, deaths = local_deaths)
}

results_list <- mclapply(
  X = seq_len(cpus_requested),
  FUN = simulate_batch,
  mc.cores = cpus_requested
)

# Convert list of vectors into a matrix for easier summing
results_matrix <- do.call(rbind, results_list)
final_stats <- colSums(results_matrix)

avg_age <- final_stats["age"] / (patients_per_core * cpus_requested)
total_deaths <- final_stats["deaths"]

output_df <- data.frame(
  dose_id = task_id,
  efficacy = dose_efficacy,
  avg_age = round(avg_age, 2),
  total_deaths = total_deaths
)

output_dir <- "results"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

filename <- file.path(output_dir, sprintf("dose_%d_results.csv", task_id))
write.csv(output_df, file = filename, row.names = FALSE, quote = FALSE)
