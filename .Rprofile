library(data.table, lib.loc='~/R')
library(lazyeval, lib.loc='~/R')
library(magrittr, lib.loc='~/R')
library(dplyr, lib.loc='~/R')
library(cframe, lib.loc='~/R')
library(ggplot2, lib.loc='~/R')
library(labeling, lib.loc='~/R')
library(digest, lib.loc='~/R')
library(bit64, lib.loc='~/R')
#library(doMC, lib.loc='~/R')
#registerDoMC(cores=2)
#install.packages('bit64', lib='~/R', dep=TRUE)

.adjustWidth <- function(...) {
    sys.width = Sys.getenv("COLUMNS")
    if (sys.width >= 10) {
        options(width=sys.width)
    }
    TRUE
}
.adjustWidthCallBack <- addTaskCallback(.adjustWidth)

h <- utils::head
