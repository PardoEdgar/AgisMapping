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
  "25m" = "black",
  "Colonies" = "darkred",
  "NC_1" = "#E5A94E",
  "NC_3" = "darkorange",
  "Poles" = "darkblue"
)

#Remove colonies that are from the other transect part. Use: |>  dplyr::filter(!Colony_ID %in% c())
Colonies_data <- Colonies_data[!duplicated(Colonies_data$Colony_ID), ]

shapes <- c(
  "25m" = 10,
  "Colonies" = 18,
  "NC_1" = 15,
  "NC_3" = 15,
  "Poles" = 16
)

View(Colonies_data)

#Tag data depending of Poles or Colonies Type (Poles are Capital letter and Colonies are numbers)
Colonies_data$Type <- case_when(
  grepl("^[A-Z]$", Colonies_data$Colony_ID) ~ "Poles",
  grepl("25m", Colonies_data$Colony_ID) ~ "25m",
  grepl("NC_1", Colonies_data$Colony_ID) ~ "NC_1",
  grepl("NC_3", Colonies_data$Colony_ID) ~ "NC_3",
  grepl("^[0-9]+$", Colonies_data$Colony_ID) |
    grepl("^unk[0-9]+$", Colonies_data$Colony_ID) ~ "Colonies",
  TRUE ~ "Other"
)


Size_table <- Colonies_data |>
  dplyr::filter(Type %in% c("NC_1", "NC_3")) |>
  arrange(Type, desc(Size)) |>
  select(Colony_ID, Type, Size)

Size_wide <- Size_table |>
  pivot_wider(names_from = Type, values_from = Colony_ID) |>
  arrange(desc(Size))

Size_wide[is.na(Size_wide)] <- "_____"

table_text <- paste(
  sprintf(" %5s    %-7s    %-6s ", "Size", "Type 1", "Type 3"),
  paste(
    sprintf(
      "   %5s    %-7s   %-6s ",
      Size_wide$Size,
      Size_wide$NC_1,
      Size_wide$NC_3
    ),
    collapse = "\n"
  ),
  sep = "\n"
)


#Create subsets of data by Type (Colonies or letter)
subset_words <- (Colonies_data[Colonies_data$Type == "Poles", ])
subset_words <- subset_words[order(subset_words$Colony_ID), ]

Table_x <- (max(Colonies_data$X_Real_World_Position) - 1.5)
#Create subtitle depending on the transect label
Subtitle_plot <- ifelse(Transect == "0to25", "0-25 m", "25-50 m")

title_name <- paste("Mud Map of coral colonies in", Site_name)

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
  ) +
  annotate(
    "label",
    x = Table_x,
    y = Inf,
    label = table_text,
    fill = alpha("#D4CC49", 0.3),
    family = "Impact",
    vjust = 4.5
  )

#ggsave("Mud_map.pdf", plot = mud_map, width = 11, height = 8.5)

#Export in pdf with 1500 width - 500 heigh to be modified in InkScape or AdobeIllustrator
#If having error saving plot, export using Rstudio or change font type and size from geom_text_repel and theme:text
