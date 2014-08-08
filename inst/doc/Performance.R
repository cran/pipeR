## ----, echo = FALSE, message = FALSE-------------------------------------
knitr::opts_chunk$set(comment="#",error=FALSE,tidy=FALSE)
set.seed(1)
library(magrittr)
library(pipeR)

## ------------------------------------------------------------------------
system.time(
  replicate(100000, {
    paste(sample(letters,6,replace = T),collapse = "") == "rstats"
    })
  )

## ------------------------------------------------------------------------
system.time(
  replicate(100000,{
    sample(letters,6,replace = T) %>%
      paste(collapse = "") %>%
      equals("rstats")
    })  
  )

## ------------------------------------------------------------------------
system.time({
  1:100000 %>>% lapply(function(i) {
    sample(letters,6,replace = T) %>>%
      paste(collapse = "") %>>%
      equals("rstats")
    })    
  })

## ------------------------------------------------------------------------
system.time(
  replicate(100000, {
    Pipe(sample(letters,6,replace = T))$
      paste(collapse = "")$
      equals("rstats") []
    })
  )

## ------------------------------------------------------------------------
# magrittr::`%>%`
system.time(lapply(1:1000, function(i) 
  rnorm(100) %>% c(rnorm(100),
    sapply(1:100, function(j) 
      rnorm(50) %>% c(rnorm(50))))))

# pipeR::`%>>%`
system.time(lapply(1:1000, function(i) 
  rnorm(100) %>>% c(rnorm(100),
    sapply(1:100, function(j) 
      rnorm(50) %>>% c(rnorm(50))))))

