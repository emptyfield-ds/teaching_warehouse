import numpy as np
import pandas as pd

np.random.seed(42)
mat = pd.DataFrame(np.random.randn(100000, 1000))

def sum_squared_diffs(df):
    result = df.apply(lambda col: np.sum((col - col.mean()) ** 2), axis=0)
    return result

sum_squared_diffs(mat)
