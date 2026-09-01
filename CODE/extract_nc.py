#!/usr/bin/env python3
# Download WFR (Full Resolution) Level 2 Sentinel-3 A and/or B OLCI data from:
# https://data.eumetsat.int/data/map/EO:EUM:DAT:0407?sort=start,time,0
# Save this code in a file named extract_nc.py in the same directory as your .zip files.
# Open the Terminal app. Type:
#  chmod +x extract_nc.py 
#  cd ~/Documents/Manuscript_2027_NC_WQ/Sentinel-3-OLCI-Data-and-Code
#  (or your directory on your local machine where the .zip files are located)
#  python extract_nc.py

import os
import zipfile
import re
import shutil

# 1. Define the directory containing the zip files ('.' means the current directory)
directory = '.' 
target_files = ['tsm_nn.nc', 'chl_nn.nc','geo_coordinates.nc']

# 2. Loop through all files in the directory
for filename in os.listdir(directory):
    if filename.endswith('.zip'):
        print(f"\nProcessing: {filename}")
        
        # 3. Extract the 8-digit date and Satellite ID (S3A or S3B)
        date_match = re.search(r'_(\d{8})T', filename)
        sat_match = re.search(r'(S3[AB])', filename)
        
        if not date_match or not sat_match:
            print("  -> Could not extract date or satellite ID (S3A/S3B), skipping.")
            continue
            
        date_str = date_match.group(1)
        sat_id = sat_match.group(1)
        zip_path = os.path.join(directory, filename)
        
        # 4. Open the zip file without extracting the whole folder
        with zipfile.ZipFile(zip_path, 'r') as z:
            for member in z.namelist():
                basename = os.path.basename(member)
                
                # If the file is one of our targets
                if basename in target_files:
                    # Construct name format: 20250819_S3A_tsm_nn.nc
                    new_name = f"{date_str}_{sat_id}_{basename}"
                    out_path = os.path.join(directory, new_name)
                    
                    # 5. Extract and save with the updated name
                    with z.open(member) as source, open(out_path, "wb") as target:
                        shutil.copyfileobj(source, target)
                        
                    print(f"  -> Extracted & renamed to: {new_name}")

print("\nDone!")