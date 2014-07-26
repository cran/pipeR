## ----, echo = FALSE, message = FALSE-------------------------------------
knitr::opts_chunk$set(comment="#",error=FALSE,tidy=FALSE)
set.seed(1)

## ------------------------------------------------------------------------
library(magrittr)

# magrittr::`%>%`
system.time(lapply(1:50000, function(i) 
  rnorm(100) %>% c(rnorm(100))))

library(pipeR)   
# pipeR::`%>>%`
system.time(lapply(1:50000, function(i) 
  rnorm(100) %>>% c(rnorm(100))))

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

