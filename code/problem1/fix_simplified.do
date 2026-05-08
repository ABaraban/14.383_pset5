
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

use "PSID-1980-1988.dta", clear
*cd programs/LFP

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

*


*3. Dynamic probit model with individual and time effects

eststo clear

*3.a. No correction
eststo FE: probitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, nocorrection


*3.b. Analytical correction, 2-lags
eststo ABC: probitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, l2


*3.c. Jackknife correction, split in time series and cross section
eststo JBC: probitfe lfp laglfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(5) i


esttab FE ABC JBC using table1.tex, ///
    se ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    mtitles("Fixed effects" "Analytical BC" "Jackknife BC") ///
    compress
	
	
******* Get APES
est restore FE
matrix col1 = e(b2)'
matrix col4 = vecdiag(e(V2))'
mata: st_matrix("col4", sqrt(st_matrix("col4")))


est restore ABC
matrix col2 = e(b2)'


est restore JBC
matrix col3 = e(b2)'


* Combine and print:
matrix results = col1, col2, col3, col4
matrix colnames results = "Fixed effects" "Analytical BC" "Jackknife BC" "SE"
matrix list results, format(%9.4f)

outtable using "table2", mat(results) replace format(%9.3f)







