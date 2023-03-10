## ---- echo=FALSE--------------------------------------------------------------
library(rmarkdown)

## ---- include = FALSE, echo = TRUE--------------------------------------------
library(cellKey)
packageVersion("cellKey")

## ---- echo = TRUE-------------------------------------------------------------
library(cellKey)
packageVersion("cellKey")

## -----------------------------------------------------------------------------
dat <- ck_create_testdata()
dat <- dat[, c("sex", "age", "savings", "income", "sampling_weight")]
dat[, cnt_highincome := ifelse(income >= 9000, 1, 0)]

## -----------------------------------------------------------------------------
dat$rkeys <- ck_generate_rkeys(dat = dat, nr_digits = 7)
print(head(dat))

## -----------------------------------------------------------------------------
dim_sex <- hier_create(root = "Total", nodes = c("male", "female"))
hier_display(dim_sex)

## -----------------------------------------------------------------------------
dim_age <- hier_create(root = "Total", nodes = paste0("age_group", 1:6))
hier_display(dim_age)

## -----------------------------------------------------------------------------
dims <- list(sex = dim_sex, age = dim_age)

## -----------------------------------------------------------------------------
tab <- ck_setup(
  x = dat,
  rkey = "rkeys",
  dims = dims,
  w = "sampling_weight",
  countvars = "cnt_highincome",
  numvars = c("income", "savings"))

## -----------------------------------------------------------------------------
print(tab)

## ---- message=FALSE, message=FALSE--------------------------------------------
# two different perturbation parameter sets from the ptable-pkg
# an example ptable provided directly
ptab1 <- ptable::pt_ex_cnts()

# creating a ptable by specifying parameters
para2 <- ptable::create_cnt_ptable(
  D = 8, V = 3, js = 2, pstay = 0.5, 
  optim = 1, mono = TRUE)

## -----------------------------------------------------------------------------
p_cnts1 <- ck_params_cnts(ptab = ptab1)
p_cnts2 <- ck_params_cnts(ptab = para2)

## -----------------------------------------------------------------------------
# use `p_cnts1` for variable "total" (which always exists)
tab$params_cnts_set(val = p_cnts1, v = "total")

# use `p_cnts2` for "cnt_highincome"
tab$params_cnts_set(val = p_cnts2, v = "cnt_highincome")

## -----------------------------------------------------------------------------
# parameters for the flex-function
p_flex <- ck_flexparams(
  fp = 1000,
  p = c(0.3, 0.03),
  epsilon = c(1, 0.5, 0.2))

## -----------------------------------------------------------------------------
# parameters for the simple approach
p_simple <- ck_simpleparams(
  p = 0.05,
  epsilon = 1)

## -----------------------------------------------------------------------------
# same ptable for all cells except for very small ones
ex_ptab1 <- ptable::pt_ex_nums(parity = TRUE, separation = TRUE)

## -----------------------------------------------------------------------------
p_nums1 <- ck_params_nums(
  type = "top_contr",
  top_k = 3,
  ptab = ex_ptab1,
  mult_params = p_flex,
  mu_c = 2,
  same_key = FALSE,
  use_zero_rkeys = TRUE)

## -----------------------------------------------------------------------------
ex_ptab2 <- ptable::pt_ex_nums(parity = FALSE, separation = FALSE)

## -----------------------------------------------------------------------------
p_nums2 <- ck_params_nums(
  type = "mean",
  ptab = ex_ptab2,
  mult_params = p_simple,
  mu_c = 1.5,
  same_key = FALSE,
  use_zero_rkeys = TRUE)

## -----------------------------------------------------------------------------
tab$params_nums_set(v = "income", val = p_nums1)
tab$params_nums_set(v = "savings", val = p_nums1)

## ---- eval = TRUE-------------------------------------------------------------
tab$supp_freq(v = "income", n = 15, weighted = FALSE)

## ---- eval = FALSE------------------------------------------------------------
#  inp <- data.frame(
#    "sex" = c("female", "male", "male"),
#    "age" = c("age_group1", "age_group3", NA)
#  )

## -----------------------------------------------------------------------------
tab$perturb(v = "total")

## -----------------------------------------------------------------------------
tab$perturb(v = c("cnt_highincome", "savings", "income"))

## -----------------------------------------------------------------------------
tab$freqtab(v = c("total", "cnt_highincome"))

## -----------------------------------------------------------------------------
tab$numtab(v = c("savings", "income"))

## -----------------------------------------------------------------------------
tab$measures_cnts(v = "total", exclude_zeros = TRUE)

## -----------------------------------------------------------------------------
tab$print() # same as (print(tab))

## -----------------------------------------------------------------------------
tab$summary()

