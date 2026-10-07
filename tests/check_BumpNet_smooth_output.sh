D=/DFS-L/DATA/whiteson/saumille/output_resonex_atlas/smoothed_hybrid/DM/NOSYS
apptainer exec -B /DFS-L/DATA/whiteson/saumille /DFS-L/DATA/whiteson/saumille/BumpNet_20250828.sif python3 - <<'EOF'
import numpy as np
from collections import Counter

D = "/DFS-L/DATA/whiteson/saumille/output_resonex_atlas/smoothed_hybrid/DM/NOSYS"
acc      = np.load(f"{D}/names.npy", allow_pickle=True)
rej      = np.load(f"{D}/rejected/names.npy", allow_pickle=True)
fit      = np.load(f"{D}/fit.npy", allow_pickle=True)
reasons  = np.load(f"{D}/rejected/fail_reason.npy", allow_pickle=True)
true_z   = np.load(f"{D}/true_z.npy", allow_pickle=True)

print(f"accepted: {len(acc)}   rejected: {len(rej)}")
print("fit types:", Counter(fit.tolist()))
print("rejection reasons:", Counter(reasons.tolist()))
zmax = [float(np.nanmax(np.abs(z))) for z in true_z]
print(f"max|Z_LR| per histogram: min={min(zmax):.2f} median={np.median(zmax):.2f} max={max(zmax):.2f}")
EOF
