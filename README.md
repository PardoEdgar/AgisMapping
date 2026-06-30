# Spatial Mapping of Tagged Coral Colonies in Rohr Reef Resilience Project, Connolly Lab, 2026
## Smithsonian Tropical Research Institute (STRI), Panama

------

## Overview
This repository provides a reproducible workflow for Spatial Mapping from 3D models and Orthomosacs built in Agisoft Metashape.
The approach combines Python and R scripts using Metashape-API to extract internal locations and convert them to Real World positions with transformation matrix.
We plotted the real world positions from tagged Coral and Poles and further edited the maps with Inkscape for better aesthetic visualization.
Here we also acquired positions of new possible tagged coral colonies using the Orthomosaics as a map and plotted them for further and easy search in fieldtrip.

---
## Contents
- `Colonies data/`: Internal and Real World colonies and poles position datasets
- `New_colonies_data/`: Internal and Real World colonies and poles position with new possible colonies to tag datasets
- `scripts/`: Python and R scripts for data extraction and building maps
- `Mud_maps/`: Complete Spatial Mapping for tagged coral colonies
- `New_colonies_Mud_Maps/`:  Complete Spatial Mapping for tagged coral colonies and new possible colones to tag

---
## Reproducibility
All scripts conducted in Python and R are provided in sequential order:
 1. `Extract_data_colonies.py`
 2. `Mud_Map.R`
 3. `New_colonies_data_extraction.py`
 4. `Mud_Map_New_Colonies.R`
 5. `Mud_Map_New_Colonies_plus_size_table.R`
    
---------------
## Requirements
### Python
  - Metashape
  - re
  - NumPy
  - Os
  - Pandas
### R 
  - tidyverse  
  - ggrepel

-------
## Data availability
All data and code required to reproduce the Spatial Mapping presented here are included in this repository.

------------
## Author
Edgar Alejandro Pardo Sarmiento, Connolly Lab

### Collaborators
Mariana Lucía Fernández, Connolly Lab

--------
## License
The source code in this repository is licensed under the MIT License.
All data and figures are licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).
