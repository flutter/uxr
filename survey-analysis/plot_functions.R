
library(ggplot2)
library(ggrepel)
library(dplyr)
library(tidyr)
library(stringr)

# ------------------------------ Helper functions ------------------------------

f.setcolors <- function(colors, length) {
  if(!is.null(colors)) {
    palette = colors
  } else {
    if(length <= 5) {
      palette = color_palette_flutter_5
    } else if (length <= 8) {
      palette = color_palette_8
    } else {
      palette = color_palette_19 
    }
  }
  return(palette)
}

# ------------------------------ Presets ------------------------------

add_conf_intv       <- geom_errorbar(aes(ymin = p - me, ymax = p + me), 
                                     position = position_dodge(width = 0.9),
                                     width = 0.1, 
                                     colour = "grey40") 
add_text            <- geom_text_repel(aes(label = paste0(round(100 * p, digits = 1), "% ")), 
                                       position = position_dodge(width = 0.9), 
                                       direction = "x",
                                       bg.color = "grey30",
                                       bg.r = 0.01,
                                       size = 3,
                                       hjust = 0, 
                                       colour = "white")
add_text_stacked    <- geom_text_repel(aes(label = paste0(round(100*p, digits = 1), "% ")),
                                       vjust = 0,
                                       hjust = 0.5,
                                       size = 3, 
                                       colour = "white", 
                                       bg.color = "grey30",
                                       bg.r = 0.01,
                                       position = "stack", 
                                       point.padding = NA, 
                                       ylim = c(0, 1)) 
theme_custom        <- theme_minimal() + 
                        theme(text = element_text(family = "Roboto", size = 12), 
                              plot.title = element_text(family = "Roboto", size = 12), 
                              axis.title = element_blank()) 
theme_custom_top    <- theme_custom + 
                        theme(legend.position="top")  
add_percent_scale   <- scale_y_continuous(labels = scales::percent, 
                                          name = "")
wrap_text           <- scale_x_discrete(labels = function(x) str_wrap(x, width = 40))

# ------------------------------ Plotting functions ------------------------------

##### f.singlechoice(): A bar plot for single choice questions
# Required parameter: qNum (Question number)
# Optional parameter: filename (Add filename, if you want to save the output plot)
#                     data (Add data to use, if you are not using the whole data)
#                     title (Add title, defaulted to use the question)
#                     orders (Add a vector of factor levels, if you want to change the order of options. 
#                             Defaulted to sort by % each option got.)
#                     colors (Add a vector of colors or a palette. Default palette differs by the # of options. See f.setcolors())
#                     topbox (Set to FALSE if you do NOT want to show the topbox value)
#                     exclude (Add a vector of options to exclude from the analysis)
#                     width, height (Set the size of output plot)

f.singlechoice <- function(qNum,
                     filename = NULL,
                     data = NULL,
                     title = NULL, 
                     orders = NULL, 
                     colors = NULL, 
                     topbox = FALSE, 
                     exclude = c(),
                     width = 7, 
                     height = 4) {
  
  if(is.null(data)) data <- all
  if(is.null(title)) title <- origin[1, qNum]
  
  set <- data %>% 
    group_by_(qNum) %>% 
    tally() %>% rename(rating = 1) %>% 
    filter(rating != "", !rating %in% exclude) %>% 
    mutate(p = n/sum(n)) %>% 
    mutate(me = 1.96 * sqrt(p * (1-p) / n))
  
  if(is.null(orders)) {
    rating_order_by_n <- set %>% arrange(desc(n)) %>% dplyr::select(rating) %>% sapply(factor)
    set$rating <- factor(set$rating, rating_order_by_n)
  } else {
    set$rating <- factor(set$rating, levels = orders)
  }
  
  palette <- f.setcolors(colors, length(set$rating))
  
  if(topbox) {
    topbox_value <- set %>% arrange(rating) %>% slice(1:2) %>% summarise(s = sum(p)) %>% as.numeric()
    topbox_value <- round(100 * topbox_value, digits = 1)
    plot_title = paste0(title, "\n(N = ", sum(set$n) , ", top-box = ", topbox_value, "%)")
  } else {
    plot_title = paste0(title, "\n(N = ", sum(set$n) ,")")
  }
  
  p <- ggplot(set, aes(x = rating, y = p)) + 
    geom_bar(aes(fill = rating), stat = "identity", width = 0.8) + 
    add_conf_intv + add_text + 
    ggtitle(plot_title)+
    scale_x_discrete(limits = rev(levels(set$rating))) + # , labels = function(x) str_wrap(x, width = 40)
    scale_y_continuous(labels = scales::percent) +
    scale_fill_manual(values = palette, guide = "none") + # c(primary, gray600)
    coord_flip() +
    theme_custom 
  
  if(!is.null(filename)) {
    ggsave(paste0("figures/", filename, ".png"), 
           p, 
           width = width, 
           height = height)
  }
  
  return(p)
}


##### f.singlechoice_breakout(): A stacked bar plot for a single choice question, brokeout by another question. (* denotes additional params)
# Required parameter: qNum (Question number)
#                     boNum* (Question number that will break out the main variable)
# Optional parameter: filename (Add filename, if you want to save the output plot)
#                     data (Add data to use, if you are not using the whole data)
#                     title (Add title, defaulted to use the question)
#                     orders (Add a vector of factor levels, if you want to change the order of options. 
#                             Defaulted to sort by % that 1st option got.)
#                     colors (Add a vector of colors or a palette. Default palette differs by the # of options. See f.setcolors())
#                     labels* (Add a vector of labels, if you want to include custom labels for a smaller legend.)
#                     q_exclude (Add a vector of options to exclude from the analysis -- from the main question)
#                     bo_exclude* (Add a vector of options to exclude from the analysis -- from the breakout question)
#                     width, height (Set the size of output plot)

f.singlechoice_breakout <- function(qNum, 
                              boNum, 
                              filename = NULL, 
                              data = NULL, 
                              title = NULL, 
                              orders = NULL, 
                              orders_bo = NULL,
                              colors = NULL, 
                              labels = NULL,
                              q_exclude = c(), 
                              bo_exclude = c(), 
                              width = 8, 
                              height = 4) {
  
  if(is.null(data)) data <- all
  
  if(is.null(title)) {
    plot_title <- paste(origin[1, qNum], "\nBy ", origin[1, boNum])
  } else {
    plot_title <- title
  }
  
  set <- data %>% 
    group_by_(boNum, qNum) %>% 
    tally() %>% 
    rename(category = 1, rating = 2) %>% 
    filter(category != "", rating != "") %>% 
    filter(!rating %in% q_exclude) %>% 
    filter(!category %in% bo_exclude) %>% 
    filter(rating != "") %>% 
    mutate(p = n/sum(n)) %>% 
    mutate(me = 1.96 * sqrt(p * (1-p) / n)) %>% 
    ungroup() %>% 
    group_by(category) %>% 
    mutate(category.n = paste0(category, "\n(N = ", sum(n), ")"))
  
  if(is.null(orders)) {
    rating_order_by_n <- set %>% 
      group_by(rating) %>% 
      summarise(sump = sum(p)) %>% 
      arrange(desc(sump)) %>% 
      dplyr::select(rating) %>% 
      sapply(factor)
    set$rating <- factor(set$rating, levels = rating_order_by_n)
    category_order_by_n <- set %>% ungroup() %>% 
      filter(rating == rating_order_by_n[1]) %>% 
      arrange(desc(p)) %>% 
      dplyr::select(category.n) %>% 
      sapply(factor)
    set$category.n <- factor(set$category.n, levels = category_order_by_n)
  } else {
    set$rating <- factor(set$rating, levels = orders)
    category_order_by_factor <- set %>% ungroup() %>% 
      filter(rating == levels(set$rating)[1]) %>% 
      arrange(desc(p)) %>% 
      dplyr::select(category.n) %>% 
      sapply(factor)
    set$category.n <- factor(set$category.n, levels = category_order_by_factor)
  }
  
  if(!is.null(orders_bo)) {
    set$category <- factor(set$category, levels = orders_bo)
    x = set[order(set$category), "category.n"]
    set$category.n <- factor(set$category.n, levels = unique(x)$category.n)
  }
  
  
  palette <- f.setcolors(colors, length(unique(set$rating)))
  
  if(is.null(labels)) {
    labels <- levels(factor(set$rating))
  }
  
  p <- ggplot(set, aes(x = category.n, y = p, fill = rating)) +
    geom_bar(position = "fill", stat = "identity", width = 0.8) +
    ggtitle(plot_title) +
    scale_fill_manual(values = palette, labels = labels) +
    guides(fill = guide_legend(reverse = T)) +
    add_text_stacked + add_percent_scale + 
    coord_flip() + 
    theme_custom_top
  
  if(!is.null(filename)) {
    ggsave(paste0("figures/", filename, ".png"), 
           p, 
           width = width, 
           height = height)
  }
  
  return(p)
}


##### f.multiplechoice(): A bar plot for multi choice questions
# Required parameter: qNum (Question number)
# Optional parameter: filename (Add filename, if you want to save the output plot)
#                     data (Add data to use, if you are not using the whole data)
#                     exclude (Add a vector of options to exclude from the analysis -- from the main question)
#                     title (Add title, defaulted to use the question)
#                     orders (Add a vector of factor levels, if you want to change the order of options. 
#                             Defaulted to sort by % that 1st option got.)
#                     colors (Add a vector of colors or a palette. Default palette differs by the # of options. See f.setcolors())
#                     width, height (Set the size of output plot)

f.multiplechoice <- function(qNum, 
                             filename = NULL, 
                             data = NULL, 
                             exclude = c(), 
                             title = NULL, 
                             orders = NULL, 
                             colors = NULL, 
                             width = 7, 
                             height = 4) {
  
  if(is.null(data)) data <- all

  select <- dplyr::select
  
  choices <- str_remove(
    str_extract(
      questions %>% 
        select(starts_with(paste0(qNum,"_")), -ends_with("TEXT"), -ends_with("RANK")),
      "-[1-9a-zA-Z].+"), 
    "-")
  
  set.wide <- data %>% 
    select(starts_with(paste0(qNum,"_"))) %>% 
    select(-ends_with("TEXT"), -ends_with("RANK")) %>% 
    filter_all(any_vars(.!="")) %>%
    rename_at(vars(starts_with(qNum)), ~choices)
  
  n_valid <- nrow(set.wide)
  
  set <- set.wide %>% 
    summarise_all(list(~sum(.!=""))) %>% 
    gather(category, n) %>% 
    filter(!category %in% exclude) %>% 
    filter(category != "Text") %>% 
    mutate(p = n/n_valid) %>% 
    mutate(me = 1.96 * sqrt(p * (1-p) / n))
  
  if(is.null(orders)) {
    category_order_by_n <- set %>% arrange(n) %>% dplyr::select(category) %>% sapply(factor)
    set$category <- factor(set$category, levels = category_order_by_n)
  } else {
    set$category <- factor(set$category, levels = orders)
  }
  
  palette <- f.setcolors(colors, length(set$category))
  
  if(is.null(title)) {
    plot_title <- paste0(sub('(.+)-.+',
                             '\\1', 
                             questions %>% dplyr::select(starts_with(qNum)))[1],
                         "\n(N = ", n_valid, ")")
  } else {
    plot_title <- paste0(title, "\n(N = ", n_valid, ")")
  }

  p <- ggplot(set , aes(x = category, y = p)) + 
    geom_bar(stat = "identity", aes(fill = category), width = 0.8) + 
    ggtitle(plot_title) +
    scale_fill_manual(values = palette, guide = "none") +
    add_conf_intv + add_text + add_percent_scale + 
    xlab("") +
    coord_flip() +
    theme_custom + wrap_text

  if(!is.null(filename)) ggsave(paste0("figures/", filename, ".png"), p, width = width, height = height)
  print(set)
  return(p)
}


##### f.matrix(): A stacked bar plot for matrix questions
# Required parameter: qNum (Question number)
# Optional parameter: filename (Add filename, if you want to save the output plot)
#                     data (Add data to use, if you are not using the whole data)
#                     exclude (Add a vector of options to exclude from the analysis -- from the main question)
#                     title (Add title, defaulted to use the question)
#                     orders (Add a vector of factor levels, if you want to change the order of options. 
#                             Defaulted to sort by % that 1st option got.)
#                     colors (Add a vector of colors or a palette. Default palette differs by the # of options. See f.setcolors())
#                     labels* (Add a vector of labels, if you want to include custom labels for a smaller legend.)
#                     width, height (Set the size of output plot)

# filename = NULL; data = NULL; exclude = c(); title = NULL; orders = NULL; colors = NULL; labels = NULL; width = 8; height = 4

f.matrix <- function(qNum, 
                     filename = NULL, 
                     data = NULL, 
                     exclude = c(), 
                     title = NULL, 
                     orders = NULL, 
                     orders2 = NULL,
                     colors = NULL, 
                     labels = NULL, 
                     width = 8, 
                     height = 4,
                     table = FALSE) {
  
  if(is.null(data)) data <- all

  select <- dplyr::select
  
  choices <- str_remove(
    str_extract(
      questions %>% 
        select(starts_with(paste0(qNum,"_")), -ends_with("TEXT"), -ends_with("RANK")),
      "-[a-zA-Z].+"), 
    "-")
  
  set.wide <- data %>% 
    select(starts_with(paste0(qNum,"_"))) %>% 
    select(-ends_with("TEXT")) %>%
    rename_at(vars(starts_with(qNum)), ~choices) %>% 
    filter_all(any_vars(.!="")) 
  
  n_valid <- nrow(set.wide)
  
  set <- set.wide %>% 
    gather("category") %>% 
    group_by(category, value) %>% 
    filter(value != "", !value %in% exclude, !category %in% exclude) %>% 
    tally() %>% 
    mutate(p = n/sum(n)) %>% 
    mutate(me = 1.96 * sqrt(p * (1-p) / n))
  
  # TODO: Make it possible to order the categories too (add another parameter)
  if(is.null(orders) & is.null(orders2)) {
    value_order_by_n <- set %>% 
      group_by(value) %>% 
      summarise(sump = sum(p)) %>% 
      arrange(desc(sump)) %>% 
      select(value) %>% 
      sapply(factor)
    set$value <- factor(set$value, levels = value_order_by_n)
    category_order_by_n <- set %>% 
      filter(value == value_order_by_n[1]) %>% 
      arrange(desc(p)) %>% 
      select(category) %>% 
      sapply(factor)
    set$category <- factor(set$category, levels = category_order_by_n)
  } else if (!is.null(orders) & is.null(orders)) {
    set$value <- factor(set$value, levels = orders)
    category_order <- set %>% 
      filter(value == orders[1]) %>% 
      arrange(desc(p)) %>% 
      select(category) %>% 
      sapply(factor)
    set$category <- factor(set$category, levels = category_order)    
  } else if(is.null(orders) & !is.null(orders2)) {
    value_order_by_n <- set %>% 
      group_by(value) %>% 
      summarise(sump = sum(p)) %>% 
      arrange(desc(sump)) %>% 
      select(value) %>% 
      sapply(factor)
    set$value <- factor(set$value, levels = value_order_by_n)
    set$category <- factor(set$category, levels = orders2)    
  } else if(!is.null(orders) & !is.null(orders2)) {
    set$value <- factor(set$value, levels = orders)
    set$category <- factor(set$category, levels = orders2)
  }
  
  palette = f.setcolors(colors, length(unique(set$value)))
  
  if(is.null(labels)) {
    labels <- levels(factor(set$value))
  }
  
  if(is.null(title)){
    plot_title <- sub("[-].*", "", questions %>% dplyr::select(starts_with(qNum)))[1]
  } else {
    plot_title <- title
  }
  
  p <- ggplot(set, aes(x = category, y = p, fill = value)) +
    geom_bar(position = "fill", stat = "identity", width = 0.8) +
    ggtitle(plot_title) + 
    scale_fill_manual(values = palette, labels = labels) +
    add_text_stacked +
    add_percent_scale + 
    coord_flip() +
    theme_custom_top + guides(fill = guide_legend(reverse = T)) +
    wrap_text
  
  if(!is.null(filename)) ggsave(paste0("figures/", filename, ".png"), 
                                p, 
                                width = width, 
                                height = height)
  if(table == TRUE) {return(list(set, p))} else {return (p)}
  # return(p)
}
