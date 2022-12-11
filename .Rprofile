#suppressWarnings(suppressMessages(local({
#    library(lazyeval)
#    library(abind)
#    library(data.table)
#    library(scales)
#    library(digest)
#    library(bit)
#    library(bit64)
#    library(hash)
#    library(lubridate)
#    library(nanotime)
#    library(ggplot2)
#    library(dtplyr)
#    library(dplyr)
#    library(purrr)
#    library(tibble)
#})))

Sys.setenv(R_HISTSIZE='999999')

options(max.print=5000)
options(tibble.width=Inf)
options(digits=10)
options(nanotimeTz='EST')

.adjustWidth <- function(...) {
    sys.width = Sys.getenv("COLUMNS")
    if (sys.width >= 10) {
        options(width=sys.width)
    }
    TRUE
}
.adjustWidthCallBack <- addTaskCallback(.adjustWidth)

if (interactive()) {
    .last <- function() try(savehistory("/home/avelazqu/.Rhistory"))
}

# my own functions in this env
.startupEnv <- new.env()

# fix for this iESS issue: https://github.com/emacs-ess/ESS/issues/1193#issuecomment-1144182009
.startupEnv$rstCol <- function() {
    try(cat(crayon::reset("")), silent = TRUE)
}

# ls as a data frame with more info
.startupEnv$lsa <- function() {
    objL <- ls(envir = .GlobalEnv)
    objClassV <- vapply(objL, function(x) paste(class(get(x, envir = .GlobalEnv)), collapse=':'), character(1))
    objSizeV <- vapply(objL, function(x) format(object.size(get(x, envir = .GlobalEnv)), unit='auto'), character(1))
    objDF <- data.frame(obj=names(objClassV), class=objClassV, size=objSizeV)
    rownames(objDF) <- NULL
    objDF
}

# ls for functions in a package
.startupEnv$lsp <-function(package, pattern, all.names = FALSE) {
    package <- deparse(substitute(package))
    ls(
        pos = paste("package", package, sep = ":"),
        all.names = all.names,
        pattern = pattern
    )
}

# head shortcut & head tail
.startupEnv$h <- utils::head
.startupEnv$ht <- function(d, n=6) rbind(head(d,n), tail(d,n))

# read multiple files
.startupEnv$glob <- function(dir, fkey, hdr, classes=NA) {
    cmd <- sprintf("cat %s/%s | sed '1!{/%s/d}'", dir, fkey, hdr)
    data.table(read.csv(pipe(cmd), header=TRUE, colClasses=classes))
}

# parse ini config
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
