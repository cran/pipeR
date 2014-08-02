

# pipeR

[![Build Status](https://travis-ci.org/renkun-ken/pipeR.png?branch=master)](https://travis-ci.org/renkun-ken/pipeR)

Specialized, high-performance pipeline operators for R: making command chaining clear, fast, readable and flexible.

[Release notes](https://github.com/renkun-ken/pipeR/releases)

## Installation

Install from CRAN:

```r
install.packages("pipeR")
```

Install the development version from GitHub (`devtools` package is required):

```r
devtools::install_github("pipeR","renkun-ken")
```

## Examples

### First-argument piping

`%>>%` operator inserts the expression on the left-hand side to the first argument of the **function** on the right-hand side.

```r
rnorm(100) %>>% 
  plot

rnorm(100) %>>% 
  plot()

rnorm(100) %>>% 
  plot(col="red")

rnorm(100) %>>% 
  sample(size=100,replace=FALSE) %>>% 
  hist
```

With the first-argument pipe operator `%>>%`, you can write code like

```r
rnorm(10000,mean=10,sd=1) %>>%
  sample(size=100,replace=FALSE) %>>%
  log %>>%
  diff %>>%
  plot(col="red",type="l")
```

### Free piping

`%:>%` takes `.` to represent the piped object on the left-hand side and evaluate the *expression* on the right-hand side.

```r
rnorm(100) %:>% 
  plot(.)

rnorm(100) %:>% 
  plot(., col="red")

rnorm(100) %:>% 
  sample(., size=length(.)*0.5)

mtcars %:>% 
  lm(mpg ~ cyl + disp, data=.) %>>% 
  summary

rnorm(100) %:>% 
  sample(.,length(.)*0.2,FALSE) %:>% 
  plot(.,main=sprintf("length: %d",length(.)))

rnorm(100) %:>% {
  par(mfrow=c(1,2))
  hist(.,main="hist")
  plot(.,col="red",main=sprintf("%d",length(.)))
}
```

### Lambda piping

`%|>%` operator evaluates a lambda expression like `x ~ f(x)` in which `x` represents the left-hand side and `f(x)` represents the right-hand side expression about `x`.

```r
mtcars %|>%
  (df ~ lm(mpg ~ ., data=df))
```

## Performance

Since these operators are specialized in their tasks, their performance is very close to traditional approach. 

Here is a simple performance test:


```r
library(magrittr)
system.time({
  lapply(1:100000, function(i) {
    sample(letters,6,replace = T) %>%
      paste(collapse = "") %>%
      equals("rstats")
  })
})
```

```
   user  system elapsed 
  30.12    0.00   30.15 
```


```r
library(pipeR)
system.time({
  lapply(1:100000, function(i) {
    sample(letters,6,replace = T) %>>%
      paste(collapse = "") %>>%
      equals("rstats")
  })
})
```

```
   user  system elapsed 
    2.7     0.0     2.7 
```

- If you want to stick to a single operator and do not consider the performance of intensive calling, you may use `%>%` in [magrittr](https://github.com/smbache/magrittr) which also provides additional aliases of basic functions. 
- If you care about performance issues and are sure which type of piping you are using, pipeR can be a helpful choice in addition to magrittr.

## Vignettes

The package also provides the following vignettes:

- [Introduction](http://cran.r-project.org/web/packages/pipeR/vignettes/Introduction.html)
- [Examples](http://cran.r-project.org/web/packages/pipeR/vignettes/Examples.html)
- [Performance](http://cran.r-project.org/web/packages/pipeR/vignettes/Performance.html)


## Help overview

```r
help(package = pipeR)
```

## License

This package is under [MIT License](http://opensource.org/licenses/MIT).
