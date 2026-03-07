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
options(nanotimeTz='America/New_York')

.adjustWidth <- function(...) {
    sys.width = suppressWarnings(as.integer(Sys.getenv("COLUMNS", "")))
    if (!is.na(sys.width) && sys.width >= 10) {
        options(width=sys.width)
    }
    TRUE
}

if (interactive()) {
    old.callback = getOption("dotfiles.adjustWidthTaskCallback")
    if (!is.null(old.callback)) {
        try(removeTaskCallback(old.callback), silent = TRUE)
    }
    options(dotfiles.adjustWidthTaskCallback=addTaskCallback(.adjustWidth))

    .Last <- function() try(savehistory(path.expand("~/.Rhistory")), silent = TRUE)
}

# my own functions in this env
if (".startupEnv" %in% search()) {
    try(detach(".startupEnv"), silent = TRUE)
}
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
    files = Sys.glob(file.path(dir, fkey))
    if (length(files) == 0) {
        stop("No files matched: ", file.path(dir, fkey))
    }

    lines = unlist(lapply(files, readLines, warn = FALSE), use.names = FALSE)
    if (length(lines) == 0) {
        return(data.frame())
    }

    keep = c(TRUE, grepl(hdr, lines[-1]))
    data = utils::read.csv(
        text = lines[keep],
        header = TRUE,
        colClasses = classes,
        stringsAsFactors = FALSE
    )

    if (requireNamespace("data.table", quietly = TRUE)) {
        data.table::as.data.table(data)
    } else {
        data
    }
}

# parse ini config
.startupEnv$parse.INI <- function(INI.filename) {
    lines = readLines(INI.filename, warn = FALSE)
    lines = trimws(sub("[;#].*$", "", lines))
    lines = lines[nzchar(lines)]

    current.section = NULL
    INI.list = list()

    for (line in lines) {
        if (grepl("^\\[.*\\]$", line)) {
            current.section = sub("^\\[(.*)\\]$", "\\1", line)
            if (!nzchar(current.section)) {
                stop("Empty section name in ", INI.filename)
            }
            if (is.null(INI.list[[current.section]])) {
                INI.list[[current.section]] = list()
            }
            next
        }

        if (is.null(current.section)) {
            stop("Key/value found before any section in ", INI.filename)
        }

        parts = strsplit(line, "=", fixed = TRUE)[[1]]
        key = trimws(parts[1])
        value = if (length(parts) > 1) trimws(paste(parts[-1], collapse = "=")) else ""

        if (!nzchar(key)) {
            next
        }

        INI.list[[current.section]][[key]] = value
    }

    INI.list
}

attach(.startupEnv)
