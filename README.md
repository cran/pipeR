

# pipeR

[![Build Status](https://travis-ci.org/renkun-ken/pipeR.png?branch=master)](https://travis-ci.org/renkun-ken/pipeR)


pipeR provides Pipe operator and function based on syntax which support to pipe value to first-argument of a function, to dot in expression, by formula as lambda expression, for side-effect, and with assignment. The set of syntax is designed to make the pipeline highly readable.

**[pipeR Tutorial](http://renkun.me/pipeR-tutorial) is a highly recommended complete guide to pipeR.**

## Installation

Install from [CRAN](http://cran.r-project.org/web/packages/pipeR/index.html):

```r
install.packages("pipeR")
```

Install the development version from GitHub:

```r
devtools::install_github("pipeR","renkun-ken")
```

## Motivation

The following code is an example written in traditional approach:

It basically performs bootstrap on `mpg` values in built-in dataset `mtcars` and plots  its density function estimated by Gaussian kernel.

```r
plot(density(sample(mtcars$mpg, size = 10000, replace = TRUE), 
  kernel = "gaussian"), col = "red", main="density of mpg (bootstrap)")
```

The code is deeply nested and can be hard to read and maintain. With Pipe operator, it can be reorganized to

```r
mtcars$mpg %>>%
  sample(size = 10000, replace = TRUE) %>>%
  density(kernel = "gaussian") %>>%
  plot(col = "red", main = "density of mpg (bootstrap)")
```

The code becomes much cleaner, more readable and more maintainable.

## Usage

### `%>>%`

Pipe operator `%>>%` basically pipes the left-hand side value forward to the right-hand side expression which is evaluated according to its syntax.

#### Pipe to first-argument of function

Many R functions are pipe-friendly: they take some data by the first argument and transform it in a certain way. This arrangement allows operations to be streamlined by pipes, that is, one data source can be put to the first argument of a function, get transformed, and put to the first argument of the next function. In this way, a chain of commands are connected, and it is called a pipeline.

On the right-hand side of `%>>%`, whenever a function name or call is supplied, the left-hand side value will always be put to the first unnamed argument to that function.

```r
rnorm(100) %>>%
  plot
```

```r
rnorm(100) %>>%
  plot(col="red")
```

Sometimes the value on the left is needed at multiple places. One can use `.` to represent it anywhere in the function call.

```r
rnorm(100) %>>%
  plot(col="red", main=length(.))
```

There are situations where one calls a function in a namespace with `::`. In this case, the call must end up with `()`.

```r
rnorm(100) %>>%
  stats::median()
  
rnorm(100) %>>%
  graphics::plot(col = "red")
```

#### Pipe to `.` in an expression

Not all functions are pipe-friendly in every case: You may find some functions do not take your data produced by a pipeline as the first argument. In this case, you can enclose your expression by `{}` or `()` so that `%>>%` will use `.` to represent the value on the left.

```r
mtcars %>>%
  { lm(mpg ~ cyl + wt, data = .) }
```

```r
mtcars %>>%
  ( lm(mpg ~ cyl + wt, data = .) )
```

#### Pipe by formula as lambda expression

Sometimes, it may look confusing to use `.` to represent the value being piped. For example,

```r
mtcars %>>%
  (lm(mpg ~ ., data = .))
```

Although it works perfectly, it may look ambiguous if `.` has several meanings in one line of code. 

`%>>%` accepts lambda expression to direct its piping behavior. Lambda expression is characterized by a formula enclosed within `()`, for example, `(x ~ f(x))`. It contains a user-defined symbol to represent the value being piped and the expression to be evaluated.

```r
mtcars %>>%
  (df ~ lm(mpg ~ ., data = df))
```

```r
mtcars %>>%
  subset(select = c(mpg, wt, cyl)) %>>%
  (x ~ plot(mpg ~ ., data = x))
```

#### Pipe for side effect

In a pipeline, one may be interested not only in the final outcome but sometimes also in intermediate results. To print, plot or save the intermediate results, it must be a side-effect to avoid breaking the mainstream pipeline. For example, calling `plot()` to draw scatter plot returns `NULL`, and if one directly calls `plot()` in the middle of a pipeline, it would break the pipeline by changing the subsequent input to `NULL`.

One-sided formula that starts with `~` indicates that the right-hand side expression will only be evaluated for its side-effect, its value will be ignored, and the input value will be returned instead.

```r
mtcars %>>%
  subset(mpg >= quantile(mpg, 0.05) & mpg <= quantile(mpg, 0.95)) %>>%
  (~ cat("rows:",nrow(.),"\n")) %>>%   # cat() returns NULL
  summary
```

```r
mtcars %>>%
  subset(mpg >= quantile(mpg, 0.05) & mpg <= quantile(mpg, 0.95)) %>>%
  (~ plot(mpg ~ wt, data = .)) %>>%    # plot() returns NULL
  (lm(mpg ~ wt, data = .)) %>>%
  summary()
```

With `~`, side-effect operations can be easily distinguished from mainstream pipeline.

An easier way to print the intermediate value it to use `(? expr)` syntax like asking question.

```r
mtcars %>>% 
  (? ncol(.)) %>>%
  summary
```

#### Pipe with assignment

In addition to printing and plotting, one may need to save an intermediate value to the environment by assigning the value to a variable (symbol).

If one needs to assign the value to a symbol, just insert a step like `(~ symbol)`, then the input value of that step will be assigned to `symbol` in the current environment.

```r
mtcars %>>%
  (lm(formula = mpg ~ wt + cyl, data = .)) %>>%
  (~ lm_mtcars) %>>%
  summary
```

If the input value is not directly to be saved but after some transformation, then one can use `=`, `<-`, or more natural `->` to specify a lambda expression to tell what to be saved (thanks @yanlinlin82 for suggestion).

```r
mtcars %>>%
  (~ summ = summary(.)) %>>%  # side-effect assignment
  (lm(formula = mpg ~ wt + cyl, data = .)) %>>%
  (~ lm_mtcars) %>>%
  summary
```

```r
mtcars %>>%
  (~ summary(.) -> summ) %>>%
  
mtcars %>>%
  (~ summ <- summary(.)) %>>%
```

An easier way to saving intermediate value that is to be further piped is to use `(symbol = expression)` syntax:

```r
mtcars %>>%
  (~ summ = summary(.)) %>>%  # side-effect assignment
  (lm_mtcars = lm(formula = mpg ~ wt + cyl, data = .)) %>>%  # continue piping
  summary
```

or `(expression -> symbol)` syntax:

```r
mtcars %>>%
  (~ summary(.) -> summ) %>>%  # side-effect assignment
  (lm(formula = mpg ~ wt + cyl, data = .) -> lm_mtcars) %>>%  # continue piping
  summary
```

#### Extract element from an object

`x %>>% (y)` means extracting the element named `y` from object `x` where `y` must be a valid symbol name and `x` can be a vector, list, environment or anything else for which `[[]]` is defined, or S4 object.

```r
mtcars %>>%
  (lm(mpg ~ wt + cyl, data = .)) %>>%
  (~ lm_mtcars) %>>%
  summary %>>%
  (r.squared)
```

#### Compatibility

* Working with [dplyr](https://github.com/hadley/dplyr/):

```r
library(dplyr)
mtcars %>>%
  filter(mpg <= mean(mpg)) %>>%  
  select(mpg, wt, cyl) %>>%
  (~ plot(.)) %>>%
  (model = lm(mpg ~ wt + cyl, data = .)) %>>%
  (summ = summary(.)) %>>%
  (coefficients)
```

* Working with [ggvis](http://ggvis.rstudio.com/):

```r
library(ggvis)
mtcars %>>%
  ggvis(~mpg, ~wt) %>>%
  layer_points()
```

* Working with [rlist](http://renkun.me/rlist/):

```r
library(rlist)
1:100 %>>%
  list.group(. %% 3) %>>%
  list.mapv(g ~ mean(g))
```

### `Pipe()`

`Pipe()` creates a Pipe object that supports light-weight chaining without any external operator. Typically, start with `Pipe()` and end with `$value` or `[]` to extract the final value of the Pipe. 

Pipe object provides an internal function `.(...)` that work exactly in the same way with `x %>>% (...)`, and it has more features than `%>>%`.

> NOTE: `.()` does not support assignment with `=` but supports `~`, `<-` and `->`.

#### Piping

```r
Pipe(rnorm(1000))$
  density(kernel = "cosine")$
  plot(col = "blue")
```

```r
Pipe(mtcars)$
  .(mpg)$
  summary()
```

```r
Pipe(mtcars)$
  .(~ summary(.) -> summ)$
  lm(formula = mpg ~ wt + cyl)$
  summary()$
  .(coefficients)
```

#### Subsetting and extracting

```r
pmtcars <- Pipe(mtcars)
pmtcars[c("mpg","wt")]$
  lm(formula = mpg ~ wt)$
  summary()
pmtcars[["mpg"]]$mean()
```

#### Assigning values

```r
plist <- Pipe(list(a=1,b=2))
plist$a <- 0
plist$b <- NULL
```

#### Side effect

```r
Pipe(mtcars)$
  .(? ncol(.))$
  .(~ plot(mpg ~ ., data = .))$    # side effect: plot
  lm(formula = mpg ~ .)$
  .(~ lm_mtcars)$                  # side effect: assign
  summary()$
```

#### Compatibility

* Working with dplyr:

```r
Pipe(mtcars)$
  filter(mpg >= mean(mpg))$
  select(mpg, wt, cyl)$
  lm(formula = mpg ~ wt + cyl)$
  summary()$
  .(coefficients)$
  value
```

* Working with ggvis:

```r
Pipe(mtcars)$
  ggvis(~ mpg, ~ wt)$
  layer_points()
```

* Working with rlist:

```r
Pipe(1:100)$
  list.group(. %% 3)$
  list.mapv(g ~ mean(g))$
  value
```

## Help overview

```r
help(package = pipeR)
```

## License

This package is under [MIT License](http://opensource.org/licenses/MIT).
