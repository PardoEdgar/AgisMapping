library(tidyverse)
library(ggrepel)
library(scales)
library(readxl)
file <- file.choose()
basename <- basename(file)

clean_basename <- basename |>
  str_remove("Colonies_data_csv_") |>
  str_remove(".csv")
print(clean_basename)

Site_name <- str_split_i(clean_basename, "_", 1)

Colonies_data <- read.csv(file)
Colonies_data <- Colonies_data |> dplyr::filter(Transect == "0to25")

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
  "Dead" = "darkgray"
)

#Remove colonies that are from the other transect part. Use: |>  dplyr::filter(!Colony_ID %in% c())
Colonies_data <- Colonies_data[!duplicated(Colonies_data$Colony_ID), ]

shapes <- c(
  #"Colonies" = 18,
  "Pc." = 17,
  "Pl." = 18,
  "Dead" = 4,
  "Poles" = 16
)
Colonies_data$Type <- case_when(
  grepl("^[A-Z]$", Colonies_data$Colony_ID) ~ "Poles",
  grepl("Dead", Colonies_data$Status) ~ "Dead",
  grepl("1", Colonies_data$type) & grepl("Alive", Colonies_data$Status) ~ "Pc.",
  grepl("3", Colonies_data$type) & grepl("Alive", Colonies_data$Status) ~ "Pl."
)

subset_words <- (Colonies_data[Colonies_data$Type == "Poles", ])
subset_words <- subset_words[order(subset_words$Colony_ID), ]

Subtitle_plot <- ifelse(Colonies_data$Transect == "0to25", "0-25 m", "25-50 m")

title_name <- paste(Site_name, Subtitle_plot)

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
  coord_fixed() +
  labs(title = title_name) +
  xlab("X (meters)") +
  ylab("Y (meters)") +
  ylim(
    min(Colonies_data$Y_Real_World_Position) - 1,
    max(Colonies_data$Y_Real_World_Position) + 2
  ) +
  xlim(
    min(Colonies_data$X_Real_World_Position) - 1,
    max(Colonies_data$X_Real_World_Position) + 2
  ) +
  geom_text_repel(
    aes(
      label = ifelse(
        is.na(type),
        Current_colony_ID,
        paste(Current_colony_ID, paste0("\n(", type, ":", species, ")"))
      )
    ),
    size = 5,
    box.padding = 1.3,
    segment.color = "black",
    family = "sans",
    direction = "both",
    max.overlaps = Inf
  ) +
  theme_void() +
  theme(
    text = element_text(family = "sans", size = 15),
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
    family = "sans",
    size = 4,
    fontface = "bold"
  )
