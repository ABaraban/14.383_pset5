
*------------------------------------------------------------------------------------------------*
*  This is an empirical application of nonlineal panel data methods to the effect of fertility on
*  female labor force participation of Fernandez-Val (2009)
*  
*  14.382 L10 MIT.  V. Chernozhukov and I. Fernandez-Val
*
* Data source: PSID 1979-1988, N = 1,461 women, T = 9 years (1979-1988)
* first year is lost to construct lagged dependent variable
*
* Description of the data: the sample selection follows
*
* Ivan Fernandez-Val, "Fixed effects estimation of structural parameters and marginal effects in 
* panel probit models," Journal of Econometrics, Elsevier, vol. 150(1), pages 71-85, May.
*
* The variables in the data set include:
*
* ID1979 = "woman identifier"
* year = "year"
* lfp = "= 1 if woman participates in labor force"
* laglfp = "lag of lfp"
* kids0_2 = "number of children of ages <= 2 years"
* kids3_5 = "number of children of ages > 2 years and < 6 years"
* kids6_17 = "number of children of ages > 5 years and < 18 years"
* loghusbandincome = "log of husband income ($1000 of 1995)"
* age = "age"
* age2 = "age squared"
*------------------------------------------------------------------------------------------------*


*-----------------------------------------------------------------------------*
cd "/Users/mcerman/Library/CloudStorage/OneDrive-MassachusettsInstituteofTechnology/Documents/2 Class/14.383/14.383_pset5/code/problem1"
*-----------------------------------------------------------------------------*

* Install code to produce nice tables

ssc install outtex, replace
ssc install sutex, replace

* Add to the folder where the probitfe and logitfe ado files are to the adopath

adopath + "/Users/mcerman/Library/CloudStorage/OneDrive-MassachusettsInstituteofTechnology/Documents/2 Class/14.383/14.383_pset5/code/problem1"


set more off
capture log close
log using results/LFP.log, text replace

use "PSID-1980-1988.dta", clear
cd programs/LFP

* Put labels to variables

label var lfp "LFP"
label var laglfp "Lagged LFP"
label var kids0_2 "Kids 0-2"
label var kids3_5 "Kids 3-5"
label var kids6_17 "Kids 6-17"
label var loghusbandincome "Log husband income in 1995 $1000"
label var age "Age"
label var age2 "Age squared"

* Specify that the data set is a panel and the variables for the dimensions

tsset ID1979 year

* Descriptive Statistics

sum

sutex

xtsum

sutex

*1. Static probit model with individual and time effects

*1.a. No correction
probitfe lfp  kids0_2 kids3_5 kids6_17 loghusbandincome age age2, nocorrection

outtex 

*1.b. Analytical correction, 0-lags
probitfe lfp  kids0_2 kids3_5 kids6_17 loghusbandincome age age2, l0

outtex


*1.c. Jackknife correction, split in time series and cross section
probitfe lfp  kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(20) i

outtex



*2. Static logit model with individual and time effects
*2.a. No correction
logitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, nocorrection

*2.b. Analytical correction, 0-lags
logitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, l0

*2.c. Jackknife correction, split in time series and cross section
logitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(20) i


*3. Dynamic probit model with individual and time effects

*3.a. No correction
probitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, nocorrection

outtex 

*3.b. Analytical correction, 2-lags
probitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, l2

outtex


*3.c. Jackknife correction, split in time series and cross section
probitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(20) i

outtex



*4. Dynamic logit model with individual and time effects
*4.a. No correction
logitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, nocorrection

*4.b. Analytical correction, 2-lags
logitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, l2

*4.c. Jackknife correction, split in time series and cross section
logitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(20) i


log close
