# Long-formatting binder for multiple datasets
#
# This is an example function named 'resolve'
# which 'resolves' similar columns a dataframe,
# returning a dataframe of the most commonly occuring character
# in all similar columns.
#
# @param data A dataframe
# @param column.name String the columns are linked by

library(magrittr)

resolve <- function(data, column.name){
  out = select(data, contains(paste(column.name))) %>%
    unite(., merge, paste(colnames(.))) %>%
    as.data.frame(.) %>%
    mutate(resolve = gsub("_", "", merge)) %>%
    apply(., 1, function(x) names(which.max(table(strsplit(x, ""))))) %>%
    data.frame(paste(toupper(column.name), "_RESOLVED"))

  return(out)
}
