library(tidyverse)
library(ggrepel)

# Seleccionar un archivo
file <- file.choose()
#Extract file name
basename <- basename(file)
#Remove characters that not include site or transect
clean_basename <- basename |>
  str_remove("Colonies_data_csv_") |>
  str_remove(".csv")
print(clean_basename)
#Extract Site_name and Transect
Site_name <- str_split_i(clean_basename, "_", 1)
Transect <- str_split_i(clean_basename, "_", 2)

#Load data
Colonies_data <- read.csv(file)

#Remove colonies that are from the other transect part. Use: |>  dplyr::filter(!Colony_ID %in% c())
Colonies_data <- Colonies_data[!duplicated(Colonies_data$Colony_ID), ]
#Tag data depending of Poles or Colonies Type (Poles are Capital letter and Colonies are numbers)
Colonies_data$Type <- ifelse(
  grepl("[A-Z]", Colonies_data$Colony_ID),
  "Poles",
  "Colonies"
)

#Create subsets of data by Type (Colonies or letter)
subset_words <- (Colonies_data[Colonies_data$Type == "Poles", ])
subset_words <- subset_words[order(subset_words$Colony_ID), ]
subset_numbers <- (Colonies_data[Colonies_data$Type == "Colonies", ])

#Create subtitle depending on the transect label
Subtitle_plot <- ifelse(Transect == "0to25", "0-25 m", "25-50 m")

title_name <- paste("Mud map of colonies in", Site_name)

#Build the map
ggplot(
  Colonies_data,
  aes(
    x = Colonies_data$X_Real_World_Position,
    y = Colonies_data$Y_Real_World_Position,
  )
) +
  scale_color_manual(values = c("darkred", "darkblue")) +
  scale_shape_manual(values = c(18, 16)) +
  geom_path(
    data = subset_words,
    aes(
      x = subset_words$X_Real_World_Position,
      y = subset_words$Y_Real_World_Position
    ),
    color = "darkblue"
  ) +
  geom_point(aes(color = Type, shape = Type), size = 7, alpha = 1) +
  #Fixed x and y axis to get relative location.
  coord_fixed() +
  labs(title = title_name, subtitle = Subtitle_plot) +
  xlab("X (meters)") +
  ylab("Y (meters)") +
  # Stablish X and Y limits
  # Add +- 1 or 2 to include colonies near the axis
  ylim(
    min(Colonies_data$Y_Real_World_Position) - 1,
    max(Colonies_data$Y_Real_World_Position) + 2
  ) +
  xlim(
    min(Colonies_data$X_Real_World_Position) - 1,
    max(Colonies_data$X_Real_World_Position) + 2
  ) +
  #Label Colonies and Poles IDs and modify vertical and horizontal justifation depending on the map
  geom_text_repel(aes(label = Colony_ID), size = 5, vjust = -1.2, hjust = 0.3) +
  #Remove axes traces
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 20),
    legend.position = "top",
  )
#Export in pdf with 1500 width - 500 heigh to be modified in InkScape or AdobeIllustrator
