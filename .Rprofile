library(data.table, lib.loc='~/R')
library(lazyeval, lib.loc='~/R')
library(magrittr, lib.loc='~/R')
library(dplyr, lib.loc='~/R')
library(cframe, lib.loc='~/R')
library(ggplot2, lib.loc='~/R')
library(labeling, lib.loc='~/R')
library(digest, lib.loc='~/R')
library(bit, lib.loc='~/R')
library(bit64, lib.loc='~/R')
library(lubridate, lib.loc='~/R')
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

#parse ini config
parse.INI <- function(INI.filename) {
    l <- readLines(INI.filename)
    l <- sub('\\#.*$', '', l)
    l <- chartr("[]", "==", l)

    con <- textConnection(l)
    x <- read.table(con, as.is=TRUE, sep='=', fill=TRUE)
    close(con)

    brk.locations <- x$V1 = ""
    x <- subset(transform(x, V3 = V2[which(brk.locations)[cumsum(brk.locations)]])[1:3], V1 != "")

    to.parse <- paste("INI.list$", x$V3, "$", x$V1, " <- '", x$V2, "'", sep="")

    INI.list <- list()
    eval(parse(text=to.parse))

    return(INI.list)
}
