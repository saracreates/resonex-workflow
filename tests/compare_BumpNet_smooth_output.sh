D=/DFS-L/DATA/whiteson/saumille/output_resonex_atlas/smoothed_hybrid/DM/NOSYS
apptainer exec -B /DFS-L/DATA/whiteson/saumille /DFS-L/DATA/whiteson/saumille/BumpNet_20250828.sif python3 - <<'EOF'
import numpy as np
from collections import Counter

D1 = "/DFS-L/DATA/whiteson/saumille/resonex/clusterrun/bumpnet/smoothed_hybrid/DM/NOSYS" # cluster run
D2 = "/DFS-L/DATA/whiteson/saumille/resonex/dummyrun/bumpnet/smoothed_hybrid/DM/NOSYS" # local run
D3 = "/DFS-L/DATA/whiteson/saumille/resonex/smoothtest1/bumpnet/smoothed_hybrid/DM/NOSYS" # cluster run 2. 

# check input data is the same 

content1      = np.load(f"{D1}/bin_content.npy", allow_pickle=True)
content2      = np.load(f"{D2}/bin_content.npy", allow_pickle=True)
content3      = np.load(f"{D3}/bin_content.npy", allow_pickle=True)

print("loaded content arrays")


count_bad_12 = 0
count_bad_23 = 0
for h1, h2, h3 in zip(content1, content2, content3, strict=True):
    for i in range(len(h1)):
        c1 = h1[i]
        c2 = h2[i]
        c3 = h3[i]
        if c1 != c2:
            print(f"content mismatch: {c1} != {c2}")
            count_bad_12 += 1
        if c2 != c3:
            print(f"content mismatch: {c2} != {c3}")
            count_bad_23 += 1

print(f"content mismatch count: {count_bad_12}, {count_bad_23}")

# then compare output 

bkg1 = np.load(f"{D1}/background.npy", allow_pickle=True) # shape (81,) 
bkg2 = np.load(f"{D2}/background.npy", allow_pickle=True)
bkg3 = np.load(f"{D3}/background.npy", allow_pickle=True)

print("loaded background arrays")

count_bad_12 = 0
count_bad_23 = 0
count_bad_13 = 0
for bkg1, bkg2, bkg3 in zip(bkg1, bkg2, bkg3, strict=True):
    for i in range(len(bkg1)):
        b1 = bkg1[i]
        b2 = bkg2[i]
        b3 = bkg3[i]
        if np.round(b1, decimals=3) != np.round(b2, decimals=3):
            print(f"background mismatch: {b1} != {b2}")
            count_bad_12 += 1
        if np.round(b2, decimals=3) != np.round(b3, decimals=3):
            print(f"background mismatch: {b2} != {b3}")
            count_bad_23 += 1
        if np.round(b1, decimals=3) != np.round(b3, decimals=3):
            print(f"background mismatch: {b1} != {b3}")
            count_bad_13 += 1
        

print(f"background mismatch count: {count_bad_12}, {count_bad_23}, {count_bad_13}")

EOF
