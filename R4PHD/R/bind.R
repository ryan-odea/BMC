# Long-formatting binder for multiple datasets
#
# This is an example function named 'bind'
# which binds together multiple datasets
# with the same column names.
#
# @param subdirectory Dataset subdirectory name
# @param file.type File type of your data, defaults to ".csv",
# @param out Specifies output format, list or row bound dataframe
# currently supports csv, sas7bdat, and xslx filetypes

bind <- function(subdirectory, file.type = "csv", out = "list"){
  if(file.type %in% c("csv", "sas7bdat", "xlsx")){
    out_list = lapply(list.files(path = subdirectory,
                     full.names = TRUE),
                if(file.type == "csv"){
                  data.table::fread
                  } else if(file.type == "sas7bdat"){
                    haven::read_sas
                  } else if(file.type == "xlsx"){
                    readxl::read_excel
                  })
  } else stop(("Only csv, sas7bdat, and xlsx files are currently supported"))
  if(out == "dataframe"){
    out_df = data.table::rbindlist(out_list, use.names = "file")
    return(out_df)
  } else if(out== "list"){
    return(out_list)
    } stop(print("Output files options are 'list' or 'dataframe'"))
}
