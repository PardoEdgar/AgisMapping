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
Colonies_data <- Colonies_data |>
  dplyr::filter(Colonies_data$Transect == "Transect2")

colors <- c(
  "Tags" = "darkorange",
  "Start" = "darkblue"
)

shapes <- c(
  "Tags" = 18,
  "Start" = 16
)

Colonies_data$Type <- case_when(
  grepl("^[A-Z]$", Colonies_data$Colony_ID) ~ "Start",
  grepl("^[1-9]", Colonies_data$Colony_ID) ~ "Tags",
)

subset_words <- (Colonies_data[Colonies_data$Type == "Start", ])
subset_words <- subset_words[order(subset_words$Colony_ID), ]

Subtitle_plot <- ifelse(Colonies_data$Transect == "Transect1", "Transect 1", "Transect 2")

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
      label = Colony_ID
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
