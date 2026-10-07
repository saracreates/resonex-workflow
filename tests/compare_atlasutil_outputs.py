"""
Compare the contents of two ROOT files using uproot.
Print differences in keys and histogram values.
Usage on greenplanet: 
'bash -c 'export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
         source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh --quiet
         lsetup "views LCG_106a_ATLAS_1 x86_64-el9-gcc14-opt"
         python compare_atlasutil_outputs.py'
"""

import uproot 

file1 = "/DFS-L/DATA/whiteson/saumille/output_histcreation/atlas_full_fixComb_fixCut_20260919_113627/histograms/atlas_opendata_full_bumpnet.root"
file2 = "/DFS-L/DATA/whiteson/saumille/resonex/dummyrun/atlas-util/histograms/atlas_opendata_full_bumpnet.root"
# yes they are the same! 

f1 = uproot.open(file1)
f2 = uproot.open(file2)

# Compare key lists
keys1 = set(f1.keys())
keys2 = set(f2.keys())
print("Keys in file1 but not in file2:", keys1 - keys2)
print("Keys in file2 but not in file1:", keys2 - keys1)
# Compare histogram contents
for key in keys1 & keys2:
    values1, edges = f1[key].to_numpy()
    values2, edges2 = f2[key].to_numpy()
    if not (values1 == values2).all():
        print(f"Difference found in histogram '{key}'")
        print("file1:", values1)
        print("file2:", values2)
        
print("Comparison complete.")
