library(tidyverse)
library(ggrepel)
library(scales)
library(readxl)
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
Colonies_data <- Colonies_data |> dplyr::filter(Transect == "25to50")

types_path <- "C:/Users/jandr/Downloads/colonies.csv"
data_types <- read_csv(types_path)
data_types$Colony_ID <- as.character(data_types$colony_id)
Colonies_data <- merge(
  Colonies_data,
  data_types,
  by = "Colony_ID",
  all.x = TRUE
)

colors <- c(
  "Pc." = "#C19A6B",
  "Pl." = "darkorange",
  "Poles" = "darkblue",
  "Caution" = "darkgreen"
)

#Remove colonies that are from the other transect part. Use: |>  dplyr::filter(!Colony_ID %in% c())
Colonies_data <- Colonies_data[!duplicated(Colonies_data$Colony_ID), ]

shapes <- c(
  #"Colonies" = 18,
  "Pc." = 17,
  "Pl." = 18,
  "Caution" = 15,
  "Poles" = 16
)

#Tag data depending of Poles or Colonies Type (Poles are Capital letter and Colonies are numbers)
Colonies_data$Type <- case_when(
  grepl("^[A-Z]$", Colonies_data$Colony_ID) ~ "Poles",
  grepl("1", Colonies_data$type) &
    grepl("yes", Colonies_data$highlight) ~ "Pc.",
  grepl("3", Colonies_data$type) &
    grepl("yes", Colonies_data$highlight) ~ "Pl.",
  grepl("no", Colonies_data$highlight) ~ "Caution",
  TRUE ~ "Other"
)

#Create subsets of data by Type (Colonies or letter)
subset_words <- (Colonies_data[Colonies_data$Type == "Poles", ])
subset_words <- subset_words[order(subset_words$Colony_ID), ]

#Create subtitle depending on the transect label
Subtitle_plot <- ifelse(Transect == "0to25", "0-25 m", "25-50 m")

title_name <- paste(Site_name, Subtitle_plot)

#Build the map
ggplot(
  Colonies_data,
  aes(
    x = Colonies_data$X_Real_World_Position,
    y = Colonies_data$Y_Real_World_Position,
  )
) +
  scale_color_manual(
    values = colors
  ) +
  scale_shape_manual(values = shapes) +
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
  labs(title = title_name) +
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
  geom_text_repel(
    aes(
      label = ifelse(
        is.na(type),
        Colony_ID,
        paste(Colony_ID, paste0("\n(", type, ":", species, ")"))
      )
    ),
    size = 5,
    box.padding = 1.3,
    segment.color = "black",
    family = "Impact",
    direction = "both",
    max.overlaps = Inf
  ) +
  #Remove axes traces
  theme_void() +
  theme(
    text = element_text(family = "Impact", size = 15),
    plot.title = element_text(hjust = 0.5, size = 23),
    legend.position = "top",
    panel.border = element_rect(
      color = "black",
      linewidth = 1.4
    )
  ) +
  annotate(
    "text",
    x = Inf,
    y = -Inf,
    label = "Connolly lab",
    hjust = 1.1,
    vjust = -0.8,
    family = "Impact",
    size = 4,
    fontface = "bold"
  )

#ggsave("Mud_map.pdf", plot = mud_map, width = 11, height = 8.5)

#Export in pdf with 1500 width - 500 heigh to be modified in InkScape or AdobeIllustrator
#If having error saving plot, export using Rstudio or change font type and size from geom_text_repel and theme:text
