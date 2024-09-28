import pandas as pd
import numpy as np

n = 1000
sim_data = pd.DataFrame({'x': np.random.normal(size=n)})

def median(i = None):
    sample_data = sim_data.sample(n, replace=True)
    return np.median(sample_data['x'])
