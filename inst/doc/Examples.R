## ----, echo = FALSE, message = FALSE-------------------------------------
knitr::opts_chunk$set(comment="#",error=FALSE,tidy=FALSE)

## ------------------------------------------------------------------------
library(dplyr)
library(pipeR)

mtcars %>>%
  select(mpg,cyl,disp,hp) %>>%
  filter(mpg <= median(mpg)) %>>%
  mutate(rmpg = mpg / max(mpg)) %>>%
  group_by(cyl) %>>%
  do(data.frame(mean=mean(.$rmpg),median=median(.$rmpg)))

## ------------------------------------------------------------------------
library(rlist)
library(pipeR)
devs <- 
  list(
    p1=list(name="Ken",age=24,
      interest=c("reading","music","movies"),
      lang=list(r=2,csharp=4,python=3)),
    p2=list(name="James",age=25,
      interest=c("sports","music"),
      lang=list(r=3,java=2,cpp=5)),
    p3=list(name="Penny",age=24,
      interest=c("movies","reading"),
      lang=list(r=1,cpp=4,python=2)))

## ------------------------------------------------------------------------
devs %>>% 
  list.filter("music" %in% interest & "r" %in% names(lang)) %>>%
  list.select(name,age) %>>%
  list.stack

## ------------------------------------------------------------------------
devs %>>%
  list.group(age) %>>%
  list.map(group -> group %>>%
      list.class(interest) %>>%
      list.map(int -> length(int))) %>>%
  str

