# install.packages("hdm")
# install.packages("xtable")
# install.packages("lmtest")
# install.packages("sandwich")
# install.packages("glmnet")
# install.packages("ggplot2")

setwd("~/classes/metrics/14.383_pset5")
library(hdm)
library(xtable)
library(lmtest)
library(sandwich)
library(glmnet) # For LassoCV
library(ggplot2)


getdata <- function(...) {
  e <- new.env()
  name <- data(..., envir = e)[1]
  e[[name]]
}

# now load your data calling getdata()
growth <- getdata(GrowthData)
growth

## Create the outcome variable y and covariates x
y <- growth$Outcome
X <- growth[-which(colnames(growth) %in% c("intercept"))]

fit <- lm(Outcome ~ ., data = X)
est <- summary(fit)$coef["gdpsh465", 1]

hcv_coefs <- vcovHC(fit, type = "HC1") # HC - "heteroskedasticity cosistent"
se <- sqrt(diag(hcv_coefs))[2] # Estimated std errors

# print unconditional effect of gdpsh465 and the corresponding standard error
cat("The estimated coefficient on gdpsh465 is", est,
    " and the corresponding robust standard error is", se)

# Calculate the 95% confidence interval for 'gdpsh465'
lower_ci <- est - 1.96 * se
upper_ci <- est + 1.96 * se

cat("95% Confidence Interval: [", lower_ci, ",", upper_ci, "]")

fit <- lm(Outcome ~ ., data = X)
est <- summary(fit)$coef["gdpsh465", 1]

hcv_coefs <- vcovHC(fit, type = "HC1") # HC - "heteroskedasticity cosistent"
se <- sqrt(diag(hcv_coefs))[2] # Estimated std errors

# print unconditional effect of gdpsh465 and the corresponding standard error
cat("The estimated coefficient on gdpsh465 is", est,
    " and the corresponding robust standard error is", se)

# Calculate the 95% confidence interval for 'gdpsh465'
lower_ci <- est - 1.96 * se
upper_ci <- est + 1.96 * se

cat("95% Confidence Interval: [", lower_ci, ",", upper_ci, "]")

# Create an empty data frame with column names
table <- data.frame(
  Method = character(0),
  Estimate = character(0),
  `Std. Error` = numeric(0),
  `Lower Bound CI` = numeric(0),
  `Upper Bound CI` = numeric(0)
)

# Add OLS results to the table
table <- rbind(table, c("OLS", est, se, lower_ci, upper_ci))

y <- growth$Outcome
W <- growth[-which(colnames(growth) %in% c("Outcome", "intercept", "gdpsh465"))]
D <- growth$gdpsh465

double_lasso <- function(y, D, W) {
  
  # residualize outcome with Lasso
  yfit_rlasso <- hdm::rlasso(W, y, post = FALSE)
  yhat_rlasso <- predict(yfit_rlasso, as.data.frame(W))
  yres <- y - as.numeric(yhat_rlasso)
  
  
  # residualize treatment with Lasso
  dfit_rlasso <- hdm::rlasso(W, D, post = FALSE)
  dhat_rlasso <- predict(dfit_rlasso, as.data.frame(W))
  dres <- D - as.numeric(dhat_rlasso)
  
  # rest is the same as in the OLS case
  hat <- mean(yres * dres) / mean(dres^2)
  epsilon <- yres - hat * dres
  V <- mean(epsilon^2 * dres^2) / mean(dres^2)^2
  stderr <- sqrt(V / length(y))
  
  list(hat = hat, stderr = stderr)
}

results <- double_lasso(y, D, W)
hat <- results$hat
stderr <- results$stderr
# Calculate the 95% confidence interval
ci_lower <- hat - 1.96 * stderr
ci_upper <- hat + 1.96 * stderr

# Add Double Lasso results to the table
table <- rbind(table, c("Double Lasso", hat, stderr, ci_lower, ci_upper))

# Print the table
print(table)

# Choose penalty based on KFold cross validation
set.seed(123)
# Given small sample size, we use an aggressive number of 20 folds
n_folds <- 20


# Define LassoCV models for y and D
model_y <- cv.glmnet(
  x = as.matrix(W),
  y = y,
  alpha = 1, # Lasso penalty
  nfolds = n_folds,
  family = "gaussian"
)

model_d <- cv.glmnet(
  x = as.matrix(W),
  y = D,
  alpha = 1, # Lasso penalty
  nfolds = n_folds,
  family = "gaussian"
)

# Get the best lambda values for y and D
best_lambda_y <- model_y$lambda.min
best_lambda_d <- model_d$lambda.min

# Fit Lasso models with the best lambda values
lasso_model_y <- glmnet(as.matrix(W), y, alpha = 1, lambda = best_lambda_y)
lasso_model_d <- glmnet(as.matrix(W), D, alpha = 1, lambda = best_lambda_d)

# Calculate the residuals
res_y <- y - predict(lasso_model_y, s = best_lambda_y, newx = as.matrix(W))
res_d <- D - predict(lasso_model_d, s = best_lambda_d, newx = as.matrix(W))


tmp_df <- as.data.frame(cbind(res_y, res_d))
colnames(tmp_df) <- c("res_y", "res_d")

fit_cv <- lm(res_y ~ res_d, data = tmp_df)
est_cv <- summary(fit_cv)$coef["res_d", 1]

hcv_cv_coefs <- vcovHC(fit_cv, type = "HC1") # HC - "heteroskedasticity cosistent"
se_cv <- sqrt(diag(hcv_cv_coefs))[2] # Estimated std errors

# Calculate the 95% confidence interval for 'gdpsh465'
lower_ci_cv <- est_cv - 1.96 * se_cv
upper_ci_cv <- est_cv + 1.96 * se_cv

# Add LassoCV results to the table
table <- rbind(table, c("Double Lasso CV", est_cv, se_cv, lower_ci_cv, upper_ci_cv))

# Print the table
print(table)


# Create a data frame to store the results
results_y <- data.frame(
  Alphas = model_y$lambda,
  OutOfSampleR2 = 1 - model_y$cvm / var(y)
)

results_d <- data.frame(
  Alphas = model_d$lambda,
  OutOfSampleR2 = 1 - model_d$cvm / var(D)
)

# Plot Outcome Lasso-CV Model
plot <- ggplot(data = results_y, aes(x = Alphas, y = OutOfSampleR2)) +
  geom_line() +
  labs(
    title = "Outcome Lasso-CV Model: Out-of-sample R-squared as function of penalty level",
    x = "Penalty Level",
    y = "Out-of-sample R-squared"
  )

print(plot)

ggsave(
  filename = "problem_3_outcome_lasso_cv_plot.png",
  plot = plot,
  width = 10,
  height = 6
)

# Plot Treatment Lasso-CV Model
plot_d <- ggplot(data = results_d, aes(x = (Alphas), y = OutOfSampleR2)) +
  geom_line() +
  labs(
    title = "Treatment Lasso-CV Model: Out-of-sample R-squared as function of penalty level",
    x = "Penalty Level",
    y = "Out-of-sample R-squared"
  )

print(plot_d)

ggsave(
  filename = "problem_3_treatment_lasso_cv_plot.png",
  plot = plot_d,
  width = 10,
  height = 6
)


