import Metashape
import re
import os
import pandas as pd
import numpy as np


def extract_names_from_colonies():
    # Access doc
    doc = Metashape.app.document
    # Access chunks
    chunks = doc.chunks
    colonies_data = []
    # Access to every chunk
    for chunk in chunks:
        # Chunk label
        chunk_label = chunk.label
        Split = chunk_label.split("_")
        Site_name = Split[0]
        Transect = Split[4]
        # Transform tool
        transform = chunk.transform.matrix
        # Accesss to all availables markers
        if chunk.markers is not None:
            for marker in chunk.markers:
                # Matching marker with a numeric label
                if (
                    re.fullmatch(r"\d+", marker.label) is not None
                    or re.fullmatch(r"unk\d+", marker.label) is not None
                    or re.fullmatch(r"[A-Z]", marker.label) 
                ):
                    if marker.label not in colonies_data:
                        # Add data to dictionary
                        Internal_Position = np.array(marker.position)
                        Real_World_Position = transform.mulp(marker.position)
                        Real_World_Position = np.array(Real_World_Position)

                        colonies_data.append(
                            {   "Transect" : Transect, 
                                "Colony_ID": marker.label,
                                "X_internal": Internal_Position[0],
                                "Y_internal": Internal_Position[1],
                                "Z_internal": Internal_Position[2],
                                # Using matrix to convert internal coordinates to world coordinates
                                "X_Real_World_Position": Real_World_Position[0],
                                "Y_Real_World_Position": Real_World_Position[1],
                                "Z_Real_World_Position": Real_World_Position[2],
                            }
                        )
                        
    print(colonies_data)
    return colonies_data, Site_name, Transect


def create_dataframe(colonies_data, Site_name, Transect):
    output_directory = Metashape.app.getExistingDirectory(
        "Select the output directory:", "C:/"
    )
    output_path = os.path.join(
        output_directory, f"Colonies_data_csv_{Site_name}_{Transect}.csv"
    )
    # Create DataFrame from data
    Colonies_data_csv = pd.DataFrame(colonies_data)
    # Create CSV from DataFrame
    Colonies_data_csv.to_csv(output_path, index=False)
    print(Colonies_data_csv)


# Run main function
def main():
    colonies_data, Site_name, Transect = extract_names_from_colonies()
    create_dataframe(colonies_data, Site_name, Transect)


# Add to tools
Metashape.app.addMenuItem("Custom/extract_colonies_data", main)
