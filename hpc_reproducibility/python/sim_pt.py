import sys
import multiprocessing
import random
import csv
import os

def simulate_batch(args):
    """
    Runs a batch of patients.
    args: tuple(num_patients, dose_efficacy, seed)
    """
    n, efficacy, seed = args
    random.seed(seed)

    total_age = 0
    local_deaths = 0

    for _ in range(n):
        age = 0
        alive = True
        while alive and age < 100:
            risk = (0.01 + (0.001 * age)) * (1.0 - efficacy)
            if random.random() < risk:
                alive = False
                local_deaths += 1
            else:
                age += 1
        total_age += age

    return total_age, local_deaths


if __name__ == "__main__":
    # parse command line arguments to set the parameters of the simulation
    task_id = int(sys.argv[1])
    cpus = int(sys.argv[2])

    TOTAL_PATIENTS = 100000
    dose_efficacy = task_id * 0.1  # 0.0, 0.1, 0.2...
    patients_per_core = TOTAL_PATIENTS // cpus

    # Prepare arguments for workers
    tasks = []
    for i in range(cpus):
        core_seed = (task_id * 1000) + i
        tasks.append((patients_per_core, dose_efficacy, core_seed))

    with multiprocessing.Pool(processes=cpus) as pool:
        results = pool.map(simulate_batch, tasks)

    # results is a list of tuples: [(age_1, death_1), (age_2, death_2)...]
    total_years = sum(r[0] for r in results)
    total_deaths = sum(r[1] for r in results)
    avg_age = total_years / TOTAL_PATIENTS

    output_dir = "results"
    os.makedirs(output_dir, exist_ok=True)

    filename = os.path.join(output_dir, f"dose_{task_id}_results.csv")

    with open(filename, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(
            ["dose_id", "efficacy", "avg_age", "total_deaths"]
        )
        writer.writerow([task_id, dose_efficacy, f"{avg_age:.2f}", total_deaths])
