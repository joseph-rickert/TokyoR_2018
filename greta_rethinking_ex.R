library(rethinking)
library(greta)
library(DiagrammeR)
library(bayesplot)
# Example from section 8.3 Statistical Rethinking
data(rugged)
d <- rugged
#names(d)
d$log_gdp <- log(d$rgdppc_2000)
#dim(d)
dd <- d[complete.cases(d$rgdppc_2000), ]
#dim(dd)

dd_trim <- dd[ , c("log_gdp","rugged","cont_africa")]
head(dd_trim)

#set seed
set.seed(1234)

# Greta Model
#data
g_log_gdp <- as_data(dd_trim$log_gdp)
g_rugged <- as_data(dd_trim$rugged)
g_cont_africa <- as_data(dd_trim$cont_africa)

# Variables and Priors

a <- normal(0, 100)
bR <- normal(0, 10)
bA <- normal(0, 10)
bAR <- normal(0,10)
sigma <- cauchy(0,2,truncation=c(0,Inf))

# operations
mu <- a + bR*g_rugged + bA*g_cont_africa + bAR*g_rugged*g_cont_africa


# likelihood
distribution(g_log_gdp) = normal(mu, sigma)

# defining the model
mod <- model(a,bR,bA,bAR,sigma)

# plotting
plot(mod)

# sampling
draws <- mcmc(mod, n_samples = 1000)
mat <- data.frame(matrix(draws[[1]],ncol=5))
names(mat) <- c("a","bR","bA","bAR","sigma")
head(mat)


library(ggplot2)
# http://www.cookbook-r.com/Graphs/Plotting_distributions_(ggplot2)/
ggplot(mat, aes(x=bAR)) + 
  geom_histogram(aes(y=..density..),      
                 binwidth=.1,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666")  


summary(draws)

# Mean      SD Naive SE Time-series SE
# a      9.2225 0.13721 0.004339       0.004773
# bR    -0.2009 0.07486 0.002367       0.002746
# bA    -1.9485 0.23033 0.007284       0.004435
# bAR    0.3992 0.13271 0.004197       0.003136
# sigma  0.9527 0.04892 0.001547       0.001744



mcmc_trace(draws)
mcmc_intervals(draws)

head(dd_trim)
