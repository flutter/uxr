# ------------------------------ Set frequently-used colors ------------------------------

flutter_yellow = "#FDAB03"
flutter_blue  = "#003D75" # very dark blue
primary_dark  = "#02569B"
primary       = "#1075C2"
gray100       = "#D5D7DA"
gray600       = "#60646B"
color_palette_flutter_5 = c(flutter_blue, primary_dark, primary, gray100, gray600)
color_palette_monochrome = rep(primary, 50)
color_palette_5       = c("#003f5c", "#58508d", "#bc5090", "#ff6361", "#ffa600") 
color_palette_8       = c("#003f5c", "#2f4b7c", "#665191", "#a05195", "#d45087", "#f95d6a", "#ff7c43", "#ffa600")
color_palette_19      = c("#512DA8", "#009688", "#FFC107", "#607D8B", "#FF5252", "#303F9F", "#388E3C", "#F57C00",
                          "#FF5722", "#5D4037", "#9E9E9E", "#FBC02D", "#00BCD4", "#9C27B0", "#CDDC39", "#03A9F4",
                          "#C2185B", "#8BC34A", "#2196F3") 
# References
# https://learnui.design/tools/data-color-picker.html#palette
# https://www.materialpalette.com/

# ------------------------------ Set frequently-used factor levels ------------------------------

satisfaction        = c("Very satisfied", "Somewhat satisfied", "Neither satisfied nor dissatisfied", 
                        "Somewhat dissatisfied", "Very dissatisfied")
satisfaction_plus1  = c("Very satisfied", "Somewhat satisfied", "Neither satisfied nor dissatisfied", 
                        "Somewhat dissatisfied", "Very dissatisfied", 
                        "I don’t have enough experience with it to answer this question")
satisfaction_wrap   = c("Very \nsatisfied", "Somewhat \nsatisfied", "Neither satisfied \nnor dissatisfied", 
                        "Somewhat \ndissatisfied", "Very \ndissatisfied")
agree               = c("Strongly agree", "Somewhat agree", "Neither agree nor disagree", "Somewhat disagree", "Strongly disagree")
agree_wrap          = c("Strongly\nagree", "Somewhat\nagree", "Neither agree\nnor disagree", "Somewhat\ndisagree", "Strongly\ndisagree")
usefulness          = c("Extremely useful", "Very useful", "Somewhat useful", "Slightly useful", "Not at all useful")
difficulty          = c("Very easy", "Somewhat easy", "Neither easy nor difficult", "Somewhat difficult", "Very difficult")
frequency           = c("Almost always", "Often", "Sometimes", "Rarely", "Nearly never")
quality_relative    = c("Much better", "Somewhat better", "About the same", "Somewhat worse", "Much worse")
acceptability       = c("Completely acceptable", "Quite acceptable", "Neither acceptable nor unacceptable", 
                        "Quite unacceptable", "Completely unacceptable")
dev_stage           = c("Published a complete production app", "Published a demo/beta app (internal or external)", 
                        "Experiment done, testing for release", "Experiment with functionality", 
                        "I am not developing an app for this platform in Flutter")
experience_level    = c("No experience", "Awareness", "Novice", "Intermediate", "Advanced", "Expert")
tenure              = c("Less than 3 months", "3 to 6 months", "6 to 12 months", "Over a year")
company_size        = c("1 employee", "2-9 employees", "10-99 employees", "100-999 employees", 
                        "1,000-9,999 employees", "Over 10,000 employees")
team_size           = c("Just me", "2-4", "5-9", "10-19", "20-49", "More than 50")
mau                 = c("1-999", "1,000-9,999", "10,000-99,999", "100,000-999,999", "1 million+")
