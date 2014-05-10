# Adapted from
# http://stackoverflow.com/questions/12913446/efficiently-create-dataframe-from-strings-containing-key-value-pairs
install.packages("ggplot2")
install.packages("hexbin")
install.packages("gplots")
library(ggplot2)
library(hexbin)
library(gplots)


setwd("c:\\Users/user/Dropbox/Documents/ABDN/Y4/PROJECT/Data/higher_benchmark/")
variable_file <- "variable.log"
benchmark_file <- "benchmark.log"

names <- setNames(1:8, c("time",    "action",    "reward",  "busy_for", "location",  "destination", "passenger", "fare"))
column_types <-        c('numeric', 'character', 'numeric', 'numeric',  'character', 'character',   'character', 'numeric')
numeric_names <- c('time', 'reward', 'busy_for', 'fare')
factor_names <- c('action', 'location', 'destination', 'passenger')

format_data <- function(file) {
  unformatted_data <- c(readLines(file))
  d1 <- gsub(", ", "=", unformatted_data)
  d2 <- gsub('"', "", d1)
  d3 <- gsub("\\[", "", d2)
  data <- gsub("\\]", ";", d3)
  data
}

assign <- function(data, names){
  pairs <- sapply(data, function(i) i)
  result <- rep(c(NA), length(names))
  keys <- names[pairs[1, ]]
  values <- pairs[2, ]
  result[keys] <- values
  result
}

data_table <- function(data) {
  sx <- lapply(strsplit(data, ";"), strsplit, "=")
  ret <- t(sapply(sx, assign, names))
  colnames(ret) <- names(names)
  res <- as.data.frame(ret, na.strings=NA, stringsAsFactors=FALSE)
  res
}

fix_types <- function(data) {
  for(name in numeric_names) {
    data[, name] <- sapply(data[, name], as.numeric)
  }
  for(name in factor_names) {
    data[, name] <- sapply(data[, name], as.factor)
  }
  data
}

lm_eqn = function(m) {
  # From http://stackoverflow.com/questions/7549694/ggplot2-adding-regression-line-equation-and-r2-on-graph
  l <- list(a = format(coef(m)[1], digits = 2),
      b = format(abs(coef(m)[2]), digits = 2),
      r2 = format(summary(m)$r.squared, digits = 3));

  if (coef(m)[2] >= 0)  {
    eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,l)
  } else {
    eq <- substitute(italic(y) == a - b %.% italic(x)*","~~italic(r)^2~"="~r2,l)    
  }

  as.character(as.expression(eq));                 
}

analysis <- function(data_frame, data_anova) {
  print(textplot(capture.output(summary(data_frame))))
  print(ggplot(data_frame, aes(x=time, y=reward)) +
            stat_bin2d(bins=100) + 
            scale_fill_gradient(low='lightblue', high='red') +
            ggtitle("Observed rewards over time"))

  print(textplot(capture.output(data_anova)))
  print(ggplot(data_frame, aes(x=time, y=reward)) +
            stat_smooth(method=lm, aes(colour="Trend (95% confidence)")) + 
            theme(legend.position = 'top') +
            ggtitle("Trend of observed rewards over time") +
            scale_colour_manual("", values = c("blue")))
}

pdf(file = 'analysis.pdf')
textplot("Variable Pricing")
variable_data <- fix_types(data_table(format_data(variable_file)))
variable_anova <- anova(lm(reward~time, data=variable_data))
analysis(variable_data, variable_anova)

textplot("Benchmark")
benchmark_data <- fix_types(data_table(format_data(benchmark_file)))
benchmark_anova <- anova(lm(reward~time, data=benchmark_data))
analysis(benchmark_data, benchmark_anova)

dev.off()
