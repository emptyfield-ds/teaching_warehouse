import polars as pl
import numpy as np
import os
import argparse

# parse command line arguments to set the parameters of the simulation
parser = argparse.ArgumentParser()
parser.add_argument("--sims", type=int, default=10000)
parser.add_argument("--subjects", type=int, default=1000)
parser.add_argument("--gamma", type=float, default=1.0)
parser.add_argument("--out", type=str, default="positivity.csv")
args = parser.parse_args()

# configure number of cores based on what we requested
threads = os.getenv("SLURM_CPUS_PER_TASK", "1")
os.environ["POLARS_MAX_THREADS"] = threads

total_rows = args.sims * args.subjects
df = pl.DataFrame(
    {
        "sim_id": np.repeat(np.arange(args.sims), args.subjects),
        "x": np.random.normal(0, 1, total_rows),
    }
)

# gamma controls the overlap. Higher Gamma = Less Overlap.
df = df.with_columns(
    (1 / (1 + (args.gamma * pl.col("x")).neg().exp())).alias("prop_score")
)

df = df.with_columns(
    (pl.Series(np.random.rand(total_rows)) < pl.col("prop_score")).alias("treatment")
)

# True ATE = 2.0
df = df.with_columns(
    (2 * pl.col("treatment") + pl.col("x") + np.random.normal(0, 1, total_rows)).alias(
        "y"
    )
)

results = df.group_by("sim_id").agg(
    [
        # IPW Estimator
        (
            (pl.col("y") * pl.col("treatment") / pl.col("prop_score"))
            - (pl.col("y") * (~pl.col("treatment")) / (1 - pl.col("prop_score")))
        )
        .mean()
        .alias("ipw_estimate"),
        # Track max weight
        pl.max_horizontal(
            [(1 / pl.col("prop_score")).max(), (1 / (1 - pl.col("prop_score"))).max()]
        ).alias("max_weight"),
    ]
)

output_dir = os.path.dirname(args.out)
if output_dir:
    os.makedirs(output_dir, exist_ok=True)

results.write_csv(args.out)
