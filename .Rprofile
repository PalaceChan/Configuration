.libPaths(c('/home/andres/R', .libPaths()))

if (interactive()) {
    suppressWarnings(suppressMessages(local({
        library(lazyeval, lib.loc='~/R')
        library(Hmisc) #cut2
        library(data.table, lib.loc='~/R') #fread/fwrite
        library(scales, lib.loc='~/R')
        library(labeling, lib.loc='~/R')
        library(digest, lib.loc='~/R')
        library(bit, lib.loc='~/R')
        library(bit64, lib.loc='~/R')
        library(lubridate, lib.loc='~/R')
        library(tidyverse, lib.loc='~/R')
    })))
}

Sys.setenv(R_HISTSIZE='999999')

options(max.print=1000)
options(tibble.width=Inf)

.adjustWidth <- function(...) {
    sys.width = Sys.getenv("COLUMNS")
    if (sys.width >= 10) {
        options(width=sys.width)
    }
    TRUE
}
.adjustWidthCallBack <- addTaskCallback(.adjustWidth)

#my own functions in this env
.startupEnv <- new.env()

#ls as a data frame with more info
.startupEnv$lsa <- function() {
    objL <- ls(envir = .GlobalEnv)
    objClassV <- vapply(objL, function(x) class(get(x, envir = .GlobalEnv)), character(1))
    objSizeV <- vapply(objL, function(x) format(object.size(get(x, envir = .GlobalEnv)), unit='auto'), character(1))
    objDF <- data.frame(obj=names(objClassV), class=objClassV, size=objSizeV)
    rownames(objDF) <- NULL
    objDF
}

#ls for functions in a package
.startupEnv$lsp <-function(package, pattern, all.names = FALSE) {
    package <- deparse(substitute(package))
    ls(
        pos = paste("package", package, sep = ":"),
        all.names = all.names,
        pattern = pattern
    )
}

#head shortcut & head tail
.startupEnv$h <- utils::head
.startupEnv$ht <- function(d, n=6) rbind(head(d,n), tail(d,n))

#read multiple files
.startupEnv$glob <- function(dir, fkey, hdr, classes=NA) {
    cmd <- sprintf("cat %s/%s | sed '1!{/%s/d}'", dir, fkey, hdr)
    data.table(read.csv(pipe(cmd), header=TRUE, colClasses=classes))
}

#parse ini config
.startupEnv$parse.INI <- function(INI.filename) {
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

attach(.startupEnv)
