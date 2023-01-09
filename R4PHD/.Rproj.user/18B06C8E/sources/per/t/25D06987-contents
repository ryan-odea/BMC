# Long-formatting binder for multiple datasets
#
# This is an example function named 'bind'
# which binds together multiple datasets
# with the same column names.
#
# @param subdirectory Dataset subdirectory name
# @param file.type File type of your data, defaults to ".csv",
# currently supports csv, sas7bdat, and xslx filetypes

bind <- function(subdirectory, file.type = "csv"){
  if(file.type %in% c("csv", "sas7bdat", "xlsx")){
    out = apply(list.files(path = subdirectory,
                     full.names = TRUE),
                if(file.type == "csv"){
                  data.table::rbindlist
                  } else if(file.type == "sas7bdat"){
                    haven::read_sas
                  } else if(file.type == "xlsx"){
                    readxl::read_excel
                  })
  } else print("Only csv, sas7bdat, and xlsx files are currently supported")
}
