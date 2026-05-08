
*******************************************************************************
type probitfe.ado
*! probitfe v2.0.2 mgonza 24jan2015

capture program drop probitfe
program probitfe, eclass byable(recall) sortpreserve
	version 11.2, missing
	local version : di "version " string(_caller()) ", missing:"
	local probitfe_cmd "probitfe"
	local cmdline "`probitfe_cmd' `*'"
	syntax varlist(min=2 fv ts) [if] [in] [,				/*
		*/ NOCorrection										/*
		*/ ANalytical										/*
		*/ 		L0 L1 L2 L3 L4								/*
		*/ JACKknife 										/*
		*/		SS1 										/*
		*/		SS2 										/*
		*/ 			MULtiple(integer 0) Individuals	Time	/*
		*/ 		JS1 										/*
		*/		JS2											/*
		*/		DOUBLE										/*
		*/ IEFFects(string)									/*
		*/ TEFFects(string)									/*
		*/ POPulation(integer 0)]

	gettoken depvar indepvar : varlist
	_fv_check_depvar `depvar'
	
*******************************************************************************
*No correction incompatibilities
	if "`nocorrection'" != "" {
		local copts "`analytical'`l0'`l1'`l2'`l3'`l4'`jackknife'`ss1'`ss2'`individuals'`time'`js1'`js2'`double'"
		if "`copts'" != "" {
			local copts "`analytical' `l0' `l1' `l2' `l3' `l4' `jackknife' `ss1' `ss2' `individuals' `time' `js1' `js2' `double'"
			local copts : list retokenize copts
di as err "Incompatible options: -nocorrection- and -`copts'-."
			exit 198
		}
		if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss2- option."
			exit 198
		}
	}

*******************************************************************************
*Validate analytical option
	if "`analytical'" != "" | ("`nocorrection'" == "" & "`analytical'" == "" & "`jackknife'" == "") {
		local copts "`ss1'`ss2'`individuals'`time'`js1'`js2'`double'"
		if "`copts'" != "" {
			local copts "`ss1' `ss2' `individuals' `time' `js1' `js2' `double'"
			local copts : list retokenize copts
di as err "Incompatible options: -analytical (the default)- and -`copts'-."
			exit 198
		}
		if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss2- option."
			exit 198
		}
		if "`l0'" != "" {
			local copts "`l1'`l2'`l3'`l4'"
			if "`copts'" != "" {
				local copts "`l1' `l2' `l3' `l4'"
				local copts : list retokenize copts
di as err "Incompatible options: -l0- and -`copts'-."
				exit 198
			}
		}
		if "`l1'" != "" {
			local copts "`l0'`l2'`l3'`l4'"
			if "`copts'" != "" {
				local copts "`l0' `l2' `l3' `l4'"
				local copts : list retokenize copts
di as err "Incompatible options: -l1- and -`copts'-."
				exit 198
			}
		}
		if "`l2'" != "" {
			local copts "`l0'`l1'`l3'`l4'"
			if "`copts'" != "" {
				local copts "`l0' `l1' `l3' `l4'"
				local copts : list retokenize copts
di as err "Incompatible options: -l2- and -`copts'-."
				exit 198
			}
		}
		if "`l3'" != "" {
			local copts "`l0'`l1'`l2'`l4'"
			if "`copts'" != "" {
				local copts "`l0' `l1' `l2' `l4'"
				local copts : list retokenize copts
di as err "Incompatible options: -l3- and -`copts'-."
				exit 198
			}
		}
		if "`l4'" != "" {
			local copts "`l0'`l1'`l2'`l3'"
			if "`copts'" != "" {
				local copts "`l0' `l1' `l2' `l3'"
				local copts : list retokenize copts
di as err "Incompatible options: -l4- and -`copts'-."
				exit 198
			}
		}
	}
		
*******************************************************************************
*Validate jackknife option
	if "`jackknife'" != "" {
		local copts "`analytical'`l0'`l1'`l2'`l3'`l4'"
		if "`copts'" != "" {
			local copts "`analytical' `l0' `l1' `l2' `l3' `l4'"
			local copts : list retokenize copts
di as err "Incompatible options: -jackknife- and -`copts'-."
			exit 198
		}
		if "`ss1'" != "" {
			local copts "`ss2'`individuals'`time'`js1'`js2'`double'"
			if "`copts'" != "" {
				local copts "`ss2' `individuals' `time' `js1' `js2' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -ss1- and -`copts'-."
			exit 198
			}
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss2- option."
			exit 198
			}
		}
		if "`ss2'" != "" {
			local copts "`ss1'`js1'`js2'`double'"
			if "`copts'" != "" {
				local copts "`ss1' `js1' `js2' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -ss2- and -`copts'-."
				exit 198
			}
			if `multiple' < 0 {
di as err "Invalid multiple option"
				exit 198
			}
		}
		if "`js1'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`js2'`double'"
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `js2' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -js1- and -`copts'-."
			exit 198
			}
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss2- option."
			exit 198
			}
		}
		if "`js2'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`js1'`double'"
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `js1' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -js2- and -`copts'-."
			exit 198
			}
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss2- option."
			exit 198
			}
		}
		if "`double'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`js1'`js2'"
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `js1' `js2'"
				local copts : list retokenize copts
di as err "Incompatible options: -double- and -`copts'-."
			exit 198
			}
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss2- option."
			exit 198
			}
		}
	}

*******************************************************************************
*Validate ieffects and teffects options
	if "`ieffects'" != "" {
		local ans Y N
		local ansnames yes no
		local ans1 : list posof "`ieffects'" in ansnames
		if !`ans1' {
di as err "Error: -ieffects- must be chosen from -`ansnames'-."
			exit 198
		}
	}
	
	if "`teffects'" != "" {
		local ans Y N
		local ansnames yes no
		local ans1 : list posof "`teffects'" in ansnames
		if !`ans1' {
di as err "Error: -teffects- must be chosen from -`ansnames'-."
			exit 198
		}
	}

	if "`ieffects'" == "no" & "`teffects'" == "no" {
di as err "Error: -ieffects(no)- and -teffects(no)- is an invalid option."
di as err "       Use the -nocorrection- option instead."
			exit 198
	}

*******************************************************************************
*Validate data are tsset
	
	capture tsset
	local pvar "`r(panelvar)'"
	local tvar "`r(timevar)'"

	if "`pvar'" == "" {
di as err "Error: must -tsset- data and specify panelvar"
		exit 5
	}

	if "`tvar'" == "" {
di as err "Error: must -tsset- data and specify timevar"
		exit 5
	}
	
	marksample touse
	markout `touse' `pvar' `tvar' `depvar' `indepvar', strok
	tsreport if `touse', panel
	
	if `r(N_gaps)' != 0 {
display in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
     */ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
	}

*******************************************************************************
*Validate (binary) depvar

	quietly tabulate `depvar' if `touse'
	if r(r) != 2 {
		display as error "Error: `depvar' is not a 0/1 variable"
		exit 198
	}
	quietly summarize `depvar' if `touse'
	if (r(min)!=0 | r(max)!=1) {
		display as error "Error: `depvar' is not a 0/1 variable"
		exit 198
	}
	
*******************************************************************************
*Check for collinearities

	local fvops = "`s(fvops)'" == "true" | _caller() >= 11
	if `fvops' {
		local rmcoll "version 11: _rmcoll"
		local fvexp expand
	}
	
	else {
		local rmcoll _rmcoll
	}
	
	tempvar tousesample
	qui g `tousesample' = `touse'
	di
	di in ye "Computing uncorrected fixed effects estimator"
	`rmcoll' `varlist' if `touse', `fvexp' probit touse(`touse')
	local varlist1 `"`r(varlist)'"'
	gettoken depvar indepvar : varlist1
	
*******************************************************************************
*Identifying individuals with all 0's or all 1's in depvar
*Identifying indepvars in which outcome does not vary
*******************************************************************************

	cap noi CheckGroups `touse' `pvar' `tvar' `depvar' `indepvar', teffects(`teffects') ieffects(`ieffects')
	local 		indepvar 	`e(varlist)'
	local 		n 			`e(n)'
	local 		ng 			`e(ng)'
	local		nt			`e(nt)'
	local 		n_orig 		`e(n_orig)'
	local 		ng_orig 	`e(ng_orig)'
	local		nt_orig		`e(nt_orig)'
	cap local 	n_drop 		`e(n_drop)'
	cap local 	ng_drop 	`e(ng_drop)'
	cap local 	nt_drop 	`e(nt_drop)'

*******************************************************************************
* Validate Finite population correction parameter
*******************************************************************************

	if `population' != 0 {
		if `population' < 0 {
di as err "Invalid population option: population must be a finite positive integer"
			exit 198
		}
		if `population' < `n_orig' {
di as err "Invalid population option: population must be a finite positive integer"
di as err "        higher or equal than the number of original observations (`n_orig')."
			exit 198
		}
	}
	
	if `population' == 0 {
		local fpc = 1
	}
	else {
		local fpc = (`population' - `n_orig')/(`population' - 1)
	}

*******************************************************************************
* Validate double option
*******************************************************************************

	if "`double'" != "" {
		tempvar sumi indexdouble
		mata: checkdouble(	"`pvar'",			/*
			*/				"`tvar'",			/*
			*/				"`tousesample'"	)
		mat `indexdouble'	= r(index)
		scalar `sumi'		= r(sum)
		local Jdouble		= rowsof(`indexdouble')
		if `sumi' == 0 {
			di as err "Invalid -double- option: no observations with the same index for `pvar' and `tvar'"
			exit 198
		}
	}

*******************************************************************************
*Individual fixed effects and time fixed effects parameters
*******************************************************************************

	if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
		local fe = 1
		local te = 0
	}
	
	else if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
		local fe = 0
		local te = 1
	}
	
	else {
		local fe = 1
		local te = 1
	}
	
*******************************************************************************
*Estimation Block
*******************************************************************************

	tempvar b V bapes Vapes
	tempname k df_m r2_p chi2 p rankV rankV2 N_drop N_group_drop N_group
	tempname T_min T_max T_avg ll ll_0
	local depname `depvar'
	local indepnames "`indepvar'"

*******************************************************************************
*Without correction
*******************************************************************************

	if "`nocorrection'" != "" {

		mata: probit(	"`depvar'",		/*
			*/			"`indepvar'",	/*
			*/			"`pvar'",		/*
			*/			"`tvar'",		/*
			*/			`n_orig',		/*
			*/			`fe',			/*
			*/			`te',			/*
			*/			`fpc',			/*
			*/			"`touse'"		)

		mat `b'			= r(b)
		mat `V'			= r(V)
		mat `bapes'		= r(bmfx)
		mat `Vapes'		= r(Vmfx)
		scalar `k'		= r(k)
		scalar `df_m'	= r(df_m)
		scalar `ll'		= r(ll)
		scalar `rankV'	= r(rank)
		scalar `T_min'	= r(T_min)
		scalar `T_max'	= r(T_max)
		scalar `T_avg'	= r(T_avg)
	}
		
*******************************************************************************
*Analytical correction
*******************************************************************************

	if "`analytical'" != ""  | ("`nocorrection'" == "" & "`analytical'" == "" & "`jackknife'" == "") {

		if "`l0'" != "" {
			local L1 = 0
			local L2 = 0
			local L3 = 0
			local L4 = 0
		}

		if "`l1'" != "" | ("`l0'" == "" & "`l1'" == "" & "`l2'" == "" & "`l3'" == "" & "`l4'" == ""){
			local L1 = 1
			local L2 = 0
			local L3 = 0
			local L4 = 0
		}

		if "`l2'" != "" {
			local L1 = 1
			local L2 = 1
			local L3 = 0
			local L4 = 0
		}

		if "`l3'" != "" {
			local L1 = 1
			local L2 = 1
			local L3 = 1
			local L4 = 0
		}

		if "`l4'" != "" {
			local L1 = 1
			local L2 = 1
			local L3 = 1
			local L4 = 1
		}

		tempvar betafe

		mata: probit(	"`depvar'",		/*
			*/			"`indepvar'",	/*
			*/			"`pvar'",		/*
			*/			"`tvar'",		/*
			*/			`n_orig',		/*
			*/			`fe',			/*
			*/			`te',			/*
			*/			`fpc',			/*
			*/			"`touse'"		)

		mat `betafe'	= r(beta)
		mat `V'			= r(V)
		mat `Vapes'		= r(Vmfx)
		scalar `k'		= r(k)
		scalar `df_m'	= r(df_m)
		scalar `rankV'	= r(rank)
		scalar `T_min'	= r(T_min)
		scalar `T_max'	= r(T_max)
		scalar `T_avg'	= r(T_avg)
		scalar `ll'		= r(ll)

		di
		di in ye "Computing analytical correction"

		mata: analytical(	"`depvar'",			/*
			*/				"`indepvar'",		/*
			*/				"`pvar'",			/*
			*/				"`tvar'",			/*
			*/				"`betafe'",			/*
			*/				`n_orig',			/*
			*/				`fe',				/*
			*/				`te',				/*
			*/				`L1',				/*
			*/				`L2',				/*
			*/				`L3',				/*
			*/				`L4',				/*
			*/				"`touse'"			)

		mat `b'     = r(b)
		mat `bapes' = r(bmfx)
	}

*******************************************************************************
*Split Jackknife in 4 subpanels
*******************************************************************************

	if "`jackknife'" != "" {
		
		if "`ss1'" != "" {
			tempvar bfe bfemfx betas betasmfx
			
			mata: probit(	"`depvar'",		/*
				*/			"`indepvar'",	/*
				*/			"`pvar'",		/*
				*/			"`tvar'",		/*
				*/			`n_orig',		/*
				*/			`fe',			/*
				*/			`te',			/*
				*/			`fpc',			/*
				*/			"`touse'"		)

			mat `bfe'		= r(b)
			mat `bfemfx'	= r(bmfx)
			mat `V'			= r(V)
			mat `Vapes'		= r(Vmfx)
			scalar `k'		= r(k)
			scalar `df_m'	= r(df_m)
			scalar `rankV'	= r(rank)
			scalar `T_min'	= r(T_min)
			scalar `T_max'	= r(T_max)
			scalar `T_avg'	= r(T_avg)
			scalar `ll'		= r(ll)
			mat `betas'		= J(4, `k', .)
			mat `betasmfx'	= J(4, `k', .)
			tempvar touse1 touse2 touse3 touse4
			qui gen byte `touse1' = `tousesample'
			qui gen byte `touse2' = `tousesample'
			qui gen byte `touse3' = `tousesample'
			qui gen byte `touse4' = `tousesample'
			
			cap noi ss1touse `tousesample' `touse1' `touse2' `touse3' `touse4' `pvar' `tvar'
			local varlist2 `touse1' `touse2' `touse3' `touse4'
					
			foreach v of local varlist2 {
				local i : list posof `"`v'"' in varlist2
				
				qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of 4"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
				
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`v'"				)

				mat `betas'[`i',1]	= r(b)
				mat `betasmfx'[`i',1]	= r(bmfx)
			}

			mata: betas_ss1(	"`bfe'",		/*
				*/				"`bfemfx'",		/*
				*/				"`betas'",		/*
				*/				"`betasmfx'"	)
				
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}

*******************************************************************************
*Split Jackknife in both dimensions: half panel out and either all T or all N
*******************************************************************************

		if "`ss2'" != "" | ("`ss1'" == "" & "`ss2'" == "" & "`js1'" == "" & "`js2'" == "" & "`double'" == "") {
			tempvar bfe bfemfx betas betasmfx
			
			mata: probit(	"`depvar'",		/*
				*/			"`indepvar'",	/*
				*/			"`pvar'",		/*
				*/			"`tvar'",		/*
				*/			`n_orig',		/*
				*/			`fe',			/*
				*/			`te',			/*
				*/			`fpc',			/*
				*/			"`touse'"		)
				
			mat `bfe'		= r(b)
			mat `bfemfx'	= r(bmfx)
			mat `V'			= r(V)
			mat `Vapes'		= r(Vmfx)
			scalar `k'		= r(k)
			scalar `df_m'	= r(df_m)
			scalar `rankV'	= r(rank)
			scalar `T_min'	= r(T_min)
			scalar `T_max'	= r(T_max)
			scalar `T_avg'	= r(T_avg)
			scalar `ll'		= r(ll)
			mat `betas'		= J(4, `k', .)
			mat `betasmfx'	= J(4, `k', .)
			tempvar touse1 touse2 touse3 touse4
			qui gen byte `touse1' = `tousesample'
			qui gen byte `touse2' = `tousesample'
			qui gen byte `touse3' = `tousesample'
			qui gen byte `touse4' = `tousesample'
			cap qui ss2touse `tousesample' `touse1' `touse2' `touse3' `touse4' `pvar' `tvar'
			local varlist2 `touse1' `touse2' `touse3' `touse4'
					
			foreach v of local varlist2 {
				local i : list posof `"`v'"' in varlist2
				
				qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of 4"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
						
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`v'"				)

				mat `betas'   [`i',1]	= r(b)
				mat `betasmfx'[`i',1]	= r(bmfx)
			}
			
			qui drop `touse1' `touse2' `touse3' `touse4'
					
			if `multiple' == 0 {
				mata: betas_ss2(	"`bfe'",		/*
					*/				"`bfemfx'",		/*
					*/				"`betas'",		/*
					*/				"`betasmfx'"	)
				mat `b'		= r(b)
				mat `bapes'	= r(bmfx)
			}
					
			else {
				tempvar betas1temp betas2temp betasmfx1temp betasmfx2temp
				mat `betas1temp'    = J(`multiple', `k' , .)
				mat `betas2temp'    = J(`multiple', `k' , .)
				mat `betasmfx1temp' = J(`multiple', `k' , .)
				mat `betasmfx2temp' = J(`multiple', `k' , .)
				set seed 123456789

				forvalues j = 1/`multiple' {
					di
					di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"
					tempvar index1 pvar2 touse1 touse2 touse3 touse4 btemp bmfxtemp
					mat `btemp'    = J(4, `k', .)
					mat `bmfxtemp' = J(4, `k', .)
					qui bysort `pvar'  : g `index1'  = runiform()  if _n==1
					qui bysort `pvar'  : g `pvar2'   = `index1'[1]
					qui tsset `pvar2' `tvar'
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui gen byte `touse3' = `tousesample'
					qui gen byte `touse4' = `tousesample'
					cap qui ss2touse `tousesample' `touse1' `touse2' `touse3' `touse4' `pvar2' `tvar'
					local varlist2 `touse1' `touse2' `touse3' `touse4'
							
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
						
						cap qui CheckGroups `v' `pvar2' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: probit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar2'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"				)

						mat `btemp'   [`i',1]	= r(b)
						mat `bmfxtemp'[`i',1]	= r(bmfx)
					}
							
					mata: betas_ss2_temp (	"`btemp'",		/*
						*/					"`bmfxtemp'" 	)
					mat `betas1temp'   [`j', 1] = r(b1)
					mat `betas2temp'   [`j', 1] = r(b2)
					mat `betasmfx1temp'[`j', 1] = r(bmfx1)
					mat `betasmfx2temp'[`j', 1] = r(bmfx2)
					mat drop `btemp' `bmfxtemp'
					qui drop `index1' `pvar2' `touse1' `touse2' `touse3' `touse4'
				}
				
				qui tsset `pvar' `tvar'
				
				if "`individuals'" != "" & "`time'" == "" {
					mata: betas_ss2i(	"`bfe'",			/*
						*/				"`bfemfx'",			/*
						*/				"`betas'",			/*
						*/				"`betasmfx'",		/*
						*/				"`betas1temp'",		/*
						*/				"`betasmfx1temp'"	)
					mat `b'		= r(b)
					mat `bapes'	= r(bmfx)
				}
					
				else if "`individuals'" == "" & "`time'" != "" {
					mata: betas_ss2t(	"`bfe'",			/*
						*/				"`bfemfx'",			/*
						*/				"`betas'",			/*
						*/				"`betasmfx'",		/*
						*/				"`betas2temp'",		/*
						*/				"`betasmfx2temp'"	)
					mat `b'		= r(b)
					mat `bapes'	= r(bmfx)
				}
					
				else {
					mata: betas_ss2it(	"`bfe'",			/*
						*/				"`bfemfx'",			/*
						*/				"`betas1temp'",		/*
						*/				"`betasmfx1temp'",	/*
						*/				"`betas2temp'",		/*
						*/				"`betasmfx2temp'"	)
					mat `b'		= r(b)
					mat `bapes'	= r(bmfx)
				}
			}
		}

*******************************************************************************
*Delete-one Jackknife in cross-section, split-panel jackknife in time-series
*******************************************************************************

		if "`js1'" != "" {
			tempvar bfe bfemfx betas betasmfx
			
			mata: probit(	"`depvar'",		/*
				*/			"`indepvar'",	/*
				*/			"`pvar'",		/*
				*/			"`tvar'",		/*
				*/			`n_orig',		/*
				*/			`fe',			/*
				*/			`te',			/*
				*/			`fpc',			/*
				*/			"`touse'"		)

			mat `bfe'		= r(b)
			mat `bfemfx'	= r(bmfx)
			mat `V'			= r(V)
			mat `Vapes'		= r(Vmfx)
			scalar `k'		= r(k)
			scalar `df_m'	= r(df_m)
			scalar `rankV'	= r(rank)
			scalar `T_min'	= r(T_min)
			scalar `T_max'	= r(T_max)
			scalar `T_avg'	= r(T_avg)
			scalar `ll'		= r(ll)
			mat `betas'		= J(2, `k', .)
			mat `betasmfx'	= J(2, `k', .)
			tempvar touse1 touse2 touse3 touse4
			qui gen byte `touse1' = `tousesample'
			qui gen byte `touse2' = `tousesample'
			qui gen byte `touse3' = `tousesample'
			qui gen byte `touse4' = `tousesample'
			cap qui ss2touse `tousesample' `touse1' `touse2' `touse3' `touse4' `pvar' `tvar'
			local varlist2 `touse3' `touse4'
					
			foreach v of local varlist2 {
				local i : list posof `"`v'"' in varlist2
				
				qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
						
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`v'"				)

				mat `betas'   [`i',1]	= r(b)
				mat `betasmfx'[`i',1]	= r(bmfx)
			}
			
			sort `pvar' `tvar' `tousesample'
			tempvar group betastemp betasmfxtemp
			qui egen `group' = group(`pvar') if `tousesample'
			qui sum `group' if `tousesample'
			local J = r(max)
			mat `betastemp'    = J(`J', `k', .)
			mat `betasmfxtemp' = J(`J', `k', .)
			
			forvalues i = 1/`J' {
				tempvar index
				qui gen byte `index' = `group' != `i' & `tousesample'
				qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of `J'"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
						
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`index'"			)

				mat `betastemp'   [`i',1]	= r(b)
				mat `betasmfxtemp'[`i',1]	= r(bmfx)
			}
			
			mata: betas_js1(	"`bfe'",			/*
					*/			"`bfemfx'",			/*
					*/			"`betas'",			/*
					*/			"`betasmfx'",		/*
					*/			"`betastemp'",		/*
					*/			"`betasmfxtemp'",	/*
					*/			`ng_orig'			)
					
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}
		
*******************************************************************************
*Delete-one Jackknife in cross-section and time-series
*******************************************************************************
		if "`js2'" != "" {
			tempvar groupp groupt bfe bfemfx betasp betasmfxp betast betasmfxt
			
			mata: probit(	"`depvar'",		/*
				*/			"`indepvar'",	/*
				*/			"`pvar'",		/*
				*/			"`tvar'",		/*
				*/			`n_orig',		/*
				*/			`fe',			/*
				*/			`te',			/*
				*/			`fpc',			/*
				*/			"`touse'"		)

			mat `bfe'		= r(b)
			mat `bfemfx'	= r(bmfx)
			mat `V'			= r(V)
			mat `Vapes'		= r(Vmfx)
			scalar `k'		= r(k)
			scalar `df_m'	= r(df_m)
			scalar `rankV'	= r(rank)
			scalar `T_min'	= r(T_min)
			scalar `T_max'	= r(T_max)
			scalar `T_avg'	= r(T_avg)
			scalar `ll'		= r(ll)
			sort `pvar' `tvar' `tousesample'
			qui egen `groupp' = group(`pvar') if `tousesample'
			qui sum `groupp' if `tousesample'
			local Jp = r(max)
			sort `pvar' `tvar' `tousesample'
			qui egen `groupt' = group(`tvar') if `tousesample'
			qui sum `groupt' if `tousesample'
			local Jt = r(max)
			mat `betasp'    = J(`Jp', `k', .)
			mat `betasmfxp' = J(`Jp', `k', .)
			mat `betast'    = J(`Jt', `k', .)
			mat `betasmfxt' = J(`Jt', `k', .)
			
			forvalues i = 1/`Jp' {
				tempvar index
				qui gen byte `index' = `groupp' != `i' & `tousesample'
				
				qui `rmcoll' `varlist' if `index', `fvexp' logit touse(`index')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of `Jp'"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
						
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`index'"			)

				mat `betasp'   [`i',1]	= r(b)
				mat `betasmfxp'[`i',1]	= r(bmfx)
				qui drop `index'
			}
			
			forvalues i = 1/`Jt' {
				tempvar index
				qui gen byte `index' = `groupt' != `i' & `tousesample'
				
				qui `rmcoll' `varlist' if `index', `fvexp' logit touse(`index')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of `Jt'"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
						
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`index'"			)

				mat `betast'   [`i',1]	= r(b)
				mat `betasmfxt'[`i',1]	= r(bmfx)
				qui drop `index'
			}
			
			mata: betas_js2(	"`bfe'",			/*
					*/			"`bfemfx'",			/*
					*/			"`betasp'",			/*
					*/			"`betasmfxp'",		/*
					*/			"`betast'",			/*
					*/			"`betasmfxt'",		/*
					*/			`ng_orig',			/*
					*/			`nt_orig'			)
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}
		
*******************************************************************************
*Double Panel Jackknife: delete i = t
*******************************************************************************

		if "`double'" != "" {
			tempvar bfe bfemfx betas betasmfx
			
			mata: probit(	"`depvar'",		/*
				*/			"`indepvar'",	/*
				*/			"`pvar'",		/*
				*/			"`tvar'",		/*
				*/			`n_orig',		/*
				*/			`fe',			/*
				*/			`te',			/*
				*/			`fpc',			/*
				*/			"`touse'"		)

			mat `bfe'		= r(b)
			mat `bfemfx'	= r(bmfx)
			mat `V'			= r(V)
			mat `Vapes'		= r(Vmfx)
			scalar `k'		= r(k)
			scalar `df_m'	= r(df_m)
			scalar `rankV'	= r(rank)
			scalar `T_min'	= r(T_min)
			scalar `T_max'	= r(T_max)
			scalar `T_avg'	= r(T_avg)
			scalar `ll'		= r(ll)
			mat `betas'     = J(`Jdouble', `k', .)
			mat `betasmfx'  = J(`Jdouble', `k', .)

			forvalues i = 1/`Jdouble' {
				tempvar index
				qui gen byte `index' = (`pvar' != `indexdouble'[`i', 1] & `tvar' != `indexdouble'[`i', 1] & `tousesample')
				
				qui `rmcoll' `varlist' if `index', `fvexp' logit touse(`index')
				local varlisttemp `"`r(varlist)'"'
				local singular : list varlist1 - varlisttemp
				di
				di in ye "Computing fixed-effects estimator in subpanel `i' of `Jdouble'"
				
				if "`singular'" != "" {
					di in gr "Warning: collinear variable(s) not in the original sample detected"
					di in gr "Collinear variables: " in ye "`singular'"
				}
				
				cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
				local 		indepvar2 		`e(varlist)'
				local 		ntemp 			`e(n)'
				local 		ngtemp 			`e(ng)'
				local 		n_origtemp 		`e(n_orig)'
				local 		ng_origtemp 	`e(ng_orig)'
						
				mata: probit_no_sd(	"`depvar'",			/*
					*/				"`indepvar2'",		/*
					*/				"`pvar'",			/*
					*/				"`tvar'",			/*
					*/				`n_origtemp',		/*
					*/				`fe',				/*
					*/				`te',				/*
					*/				"`index'"			)

				mat `betas'   [`i',1]	= r(b)
				mat `betasmfx'[`i',1]	= r(bmfx)
				qui drop `index'
			}
			
			mata: betas_double(	"`bfe'",			/*
					*/			"`bfemfx'",			/*
					*/			"`betas'",			/*
					*/			"`betasmfx'",		/*
					*/			`Jdouble'			)
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
	
		}
	}

********************************************************************************
* Done with estimation block
********************************************************************************

	mat colnames `b' = `indepnames'
	mat colnames `V' = `indepnames'
	mat rownames `V' = `indepnames'
	mat colnames `bapes' = `indepnames'
	mat colnames `Vapes' = `indepnames'
	mat rownames `Vapes' = `indepnames'
	
********************************************************************************
* r2_p, chi2, p
********************************************************************************

	qui mata: probitconstantonly(	"`depvar'",		/*
			*/						"`touse'"	)

	scalar `ll_0'	= r(ll_0)
	scalar `r2_p'	= 1 - `ll'/`ll_0'
	scalar `chi2'	= 2 * (`ll' - `ll_0')
	scalar `p'		= chiprob(`df_m', `chi2')

*********************************************************************************
* Post and display results
*********************************************************************************
	
	tempname btemp Vtemp bapestemp Vapestemp
	mat `btemp' 			= `b'
	mat `Vtemp' 			= `V'
	mat `bapestemp' 		= `bapes'
	mat `Vapestemp' 		= `Vapes'
	qui count if `touse'
	local N 				= r(N)
	capture ereturn post `b' `V', dep(`depname') obs(`N') esample(`touse')
	ereturn matrix	b2 		`bapes'
	ereturn matrix	V2 		`Vapes'
	ereturn local	cmd 	`probitfe_cmd'
	ereturn local 	cmdline `cmdline'
	ereturn local 	chi2type "LR"
	ereturn local 	id 		`pvar'
	ereturn local 	time 	`tvar'
	ereturn scalar 	k		= `k'
	ereturn scalar 	df_m	= `df_m'
	ereturn scalar 	ll		= `ll'
	ereturn scalar 	rankV	= `rankV'
	ereturn scalar 	rankV2	= `rankV'
	ereturn scalar 	ll_0	= `ll_0'
	ereturn scalar 	r2_p	= `r2_p'
	ereturn scalar 	chi2	= `chi2'
	ereturn scalar 	p		= `p'
	
	if `n' < `n_orig' {
	
		if (`ng_orig' - `ng' > 1) | (`nt_orig' - `nt' > 1) {
			ereturn scalar N_drop = `n_orig' - `n'
			ereturn scalar N_group_drop = `ng_orig' - `ng'
			ereturn scalar N_time_drop = `nt_orig' - `nt'
		}
	}
	ereturn scalar N_group	= `ng'
	ereturn scalar T_min	= `T_min'
	ereturn scalar T_max	= `T_max'
	ereturn scalar T_avg	= `T_avg'
	ereturn scalar fpc		= `fpc'
		
	if "`nocorrection'" != "" {
		local title "Uncorrected fixed-effects estimates"
		if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
			local title1 "Individual effects only"
		}
		if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
			local title1 "Time effects only"
		}
		if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
			local title1 "Individual and time effects"
		}
	}
	if "`analytical'" != "" | ("`nocorrection'" == "" & "`analytical'" == "" & "`jackknife'" == "") {
		local title "Analytical bias-correction"
		if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
			local title1 "Type of correction: individual effects only"
		}
		if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
			local title1 "Type of correction: time effects only"
		}
		if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
			local title1 "Type of correction: individual and time effects"
		}
		if "`l0'" != "" {
			local title2 "Trimming parameter = 0"
		}
		if "`l1'" != "" | ("`l0'" == "" & "`l1'" == "" & "`l2'" == "" & "`l3'" == "" & "`l4'" == "") {
			local title2 "Trimming parameter = 1"
		}
		if "`l2'" != "" {
			local title2 "Trimming parameter = 2"
		}
		if "`l3'" != "" {
			local title2 "Trimming parameter = 3"
		}
		if "`l4'" != "" {
			local title2 "Trimming parameter = 4"
		}
	}
	if "`jackknife'" != "" {
		if "`ss1'" != "" {
			local title "Split-panel jackknife in four subpanels"
			if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
				local title1 "Type of correction: individual effects only"
			}
			if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
				local title1 "Type of correction: time effects only"
			}
			if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
				local title1 "Type of correction: individual and time effects"
			}
		}
		if "`ss2'" != "" | ("`ss1'" == "" & "`ss2'" == "" & "`js1'" == "" & "`js2'" == "" & "`double'" == "") {
			local title "Split-panel jackknife in both dimensions"
			if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
				local title1 "Type of correction: individual effects only"
			}
			if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
				local title1 "Type of correction: time effects only"
			}
			if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
				local title1 "Type of correction: individual and time effects"
			}
			if `multiple' > 0 {
				if "`individuals'" != "" & "`time'" == "" {
					local title2 `multiple' multiple partitions in the cross-section dimension
				}
				else if "`individuals'" == "" & "`time'" != "" {
					local title2 `multiple' multiple partitions in the time dimension
				}
				else {
					local title2 `multiple' multiple partitions in both the cross-section and the time dimension
				}
			}
		}
		if "`js1'" != "" {
			local title "Delete-one jackknife in cross-section, split-panel in time series"
			if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
				local title1 "Type of correction: individual effects only"
			}
			if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
				local title1 "Type of correction: time effects only"
			}
			if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
				local title1 "Type of correction: individual and time effects"
			}
		}
		if "`js2'" != "" {
			local title "Delete-one jackknife in cross-section and time series"
			if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
				local title1 "Type of correction: individual effects only"
			}
			if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
				local title1 "Type of correction: time effects only"
			}
			if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
				local title1 "Type of correction: individual and time effects"
			}
		}
		if "`double'" != "" {
			local title "Double-panel jackknife"
			if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
				local title1 "Type of correction: individual effects only"
			}
			if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
				local title1 "Type of correction: time effects only"
			}
			if ("`ieffects'" == ""    & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == "yes") | /*
			*/ ("`ieffects'" == ""    & "`teffects'" == ""   ) | /*
			*/ ("`ieffects'" == "yes" & "`teffects'" == ""   ) {
				local title1 "Type of correction: individual and time effects"
			}
		}
	}
	local title3 "Average Partial Effects"
	ereturn local title `title'
	capture ereturn local title2 `title2'
	ereturn local title1 `title1'
		
di in gr _n "`e(title)'"
di in gr  "`e(title1)'"
	local tlen=length("`e(title1)'")
di in gr "{hline `tlen'}"
	if "`e(title2)'" != "" {
di in gr "`e(title2)'"
	}
di in gr "ID variable    = " in ye e(id) _continue
di in gr _col(48) "Number of obs.       = " in ye %8.0f e(N)
di in gr "Time variable  = " in ye e(time) _continue
di in gr _col(48) "Number of groups     = " in ye %8.0f e(N_group)
di in gr _col(48) "Obs. per group: min  = " in ye %8.0f e(T_min)
di in gr _col(48) "                avg  = " in ye %8.1f e(T_avg)
di in gr _col(48) "                max  = " in ye %8.0f e(T_max)
di in gr _col(48) "LR chi2(" in ye %4.0f e(df_m) in gr ")        = " in ye %8.2f e(chi2)
di in gr _col(48) "Prob > chi2          = " in ye %8.4f e(p)
di in gr "Log-likelihood = " in ye %12.0g e(ll) _continue
di in gr _col(48) "Pseudo R2            = " in ye %8.4f e(r2_p)
di
	ereturn display, noempty
	ereturn repost b = `bapestemp' V = `Vapestemp'
di in ye "`title3'"
	if e(fpc) != 1 {
di in gr "Variance adjusted by the finite population parameter " in ye %8.4f e(fpc)
	}
	ereturn display, noempty
	ereturn repost b = `btemp' V = `Vtemp'
end

*******************************************************************************
*Subroutines
*******************************************************************************

capture program drop Disp
program define Disp 
	version 8.2
	syntax [anything] [, _col(integer 15) ]
	local len = 80-`_col'+1
	local piece : piece 1 `len' of `"`anything'"'
	local i 1
	while "`piece'" != "" {
		di in gr _col(`_col') "`first'`piece'"
		local i = `i' + 1
		local piece : piece `i' `len' of `"`anything'"'
	}
	if `i'==1 {
		di
	}
end

capture program drop ss1touse
program define ss1touse, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist
	gettoken touse  varlist : varlist
	gettoken touse1 varlist : varlist
	gettoken touse2 varlist : varlist
	gettoken touse3 varlist : varlist
	gettoken touse4 varlist : varlist
	gettoken pvar   tvar    : varlist
	tempvar N t1 t2 h1 h2 i1 i2 i3 i4
	sort `touse' `pvar' `tvar'
	qui by `touse' `pvar' : gen byte `t1' = cond(_n <= ceil(_N/2), 1, 0) if `touse'
	qui by `touse' `pvar' : gen byte `t2' = cond(ceil(_N/2) == floor(_N/2), /*
		*/ cond(_n > ceil(_N/2), 1, 0), cond(_n >= ceil(_N/2), 1, 0)) if `touse'
	qui egen `N' = group(`pvar') if `touse'
	qui sum `N' if `touse'
	sort `touse' `pvar' `tvar'
	qui by `touse' `pvar' : gen byte `h1' = cond(`N' <= ceil(r(max)/2), 1, 0) if `touse'
	qui by `touse' `pvar' : gen byte `h2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`N' > ceil(r(max)/2), 1, 0), cond(`N' >= ceil(r(max)/2), 1, 0)) if `touse'
	
**Bottom half panel out, first half of time periods
	qui gen byte `i1' = (`t1' & `h1' & `touse')
	qui replace `touse1' = `i1'
**Bottom half panel out, second half of time periods
	qui gen byte `i2' = (`t2' & `h1' & `touse')
	qui replace `touse2' = `i2'
**Top half panel out, first half of time periods
	qui gen byte `i3' = (`t1' & `h2' & `touse')
	qui replace `touse3' = `i3'
**Top half panel out, second half of time periods
	qui gen byte `i4' = (`t2' & `h2' & `touse')
	qui replace `touse4' = `i4'
	
end

capture program drop ss2touse
program define ss2touse, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist
	gettoken touse  varlist : varlist
	gettoken touse1 varlist : varlist
	gettoken touse2 varlist : varlist
	gettoken touse3 varlist : varlist
	gettoken touse4 varlist : varlist
	gettoken pvar   tvar    : varlist
	tempvar N t1 t2 h1 h2 i1 i2 i3 i4
	qui sort `touse' `pvar' `tvar'
	qui by `touse' `pvar' : gen byte `t1' = cond(_n <= ceil(_N/2), 1, 0) if `touse'
	qui by `touse' `pvar' : gen byte `t2' = cond(ceil(_N/2) == floor(_N/2), /*
		*/ cond(_n > ceil(_N/2), 1, 0), cond(_n >= ceil(_N/2), 1, 0)) if `touse'
	qui egen `N' = group(`pvar') if `touse'
	qui sum `N' if `touse'
	qui sort `touse' `pvar' `tvar'
	qui by `touse' `pvar' : gen byte `h1' = cond(`N' <= ceil(r(max)/2), 1, 0) if `touse'
	qui by `touse' `pvar' : gen byte `h2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`N' > ceil(r(max)/2), 1, 0), cond(`N' >= ceil(r(max)/2), 1, 0)) if `touse'
	
**Bottom half panel out, all time periods
	qui gen byte `i1' = (`h1' & `touse')
	qui replace `touse1' = `i1'
**Top half panel out, all time periods
	qui gen byte `i2' = (`h2' & `touse')
	qui replace `touse2' = `i2'
**All individuals, first half of time periods
	qui gen byte `i3' = (`t1' & `touse')
	qui replace `touse3' = `i3'
**All individuals, second half of time periods
	qui gen byte `i4' = (`t2' & `touse')
	qui replace `touse4' = `i4'

end
	
capture program drop CheckGroups
program define CheckGroups, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist(fv ts)[, IEFFects(string) TEFFects(string)]
	gettoken touse varlist     : varlist
	gettoken pvar  varlist     : varlist
	gettoken tvar  varlist     : varlist
	gettoken depvar indepvar   : varlist
	
*******************************************************************************
* Only individual effects
*******************************************************************************

if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
	sort `touse' `pvar'
	
*Check outcome varies for at least one individual

	cap by `touse' `pvar' : assert `depvar' == `depvar'[1] if `touse' 
	
	if !_rc {
		di as err "Outcome does not vary for any individual"
		exit 2000 
	}

*Check for multiple positive outcomes accross individuals
	
	tempvar sumdep
	qui by `touse' `pvar' : gen double `sumdep' = cond(_n == _N, sum(`depvar'), .) if `touse'
	qui count if `sumdep' > 1 & `sumdep' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "groups encountered"
		local multiple multiple
	}

*Delete groups where outcome doesn't vary.

	CountObsGroups `touse' `pvar'
	local n_orig = r(n)
	local ng_orig = r(ng)
	sort `touse' `tvar'
	CountObsGroups `touse' `tvar'
	local nt_orig = r(ng)
	local nt = `nt_orig'
	sort `touse' `pvar'
	tempvar varies rtouse
	qui by `touse' `pvar': gen byte `varies' = cond(_n==_N, sum(`depvar'!=`depvar'[1]), .) if `touse'
	qui by `touse' `pvar': gen byte `rtouse' = (`varies'[_N]>0) & `touse'
	qui replace `touse' = `rtouse'
	sort `touse' `pvar'

	CountObsGroups `touse' `pvar'
	local n = r(n)
	local ng = r(ng)
	
	if `n' < `n_orig' {
	
		if `ng_orig'-`ng' > 1 {
			local s s
		}
		
		di as txt "note: " `ng_orig'-`ng' " group`s' (" _c
		di as txt `n_orig'-`n' _c 
		di as txt " obs) dropped because of all positive or"
		di as txt "      all negative outcomes"
		local ng_drop	= `ng_orig' - `ng'
		local n_drop	= `n_orig' - `n'
	}

*Check that each depvar varies in at least 1 group.

		capture tsset
		local pvar "`r(panelvar)'"
		local tvar "`r(timevar)'"
		markout `touse' `pvar' `tvar' `depvar' `indepvar', strok
		sort `pvar' `tvar' `touse'
		
		if `"`indepvar'"' != "" {
			fvexpand `indepvar'
			local indepvar "`r(varlist)'"
			
			foreach v of local indepvar {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `pvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-group variance"		

						if _caller() < 11 {
							local v
						}
					
						else local v o.`v'
					}
				}
				
				local xs `xs' `v'
			}
		}
		
		local indepvar `xs'
}

*******************************************************************************
* Only time effects
*******************************************************************************

else if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
	sort `touse' `tvar'

*Check outcome varies for at least one individual

	cap by `touse' `tvar' : assert `depvar' == `depvar'[1] if `touse' 
	
	if !_rc {
			di as err "outcome does not vary for any time period"
			exit 2000 
	}

*Check for multiple positive outcomes accross individuals

	tempvar sumdep
	qui by `touse' `tvar' : gen double `sumdep' = cond(_n == _N, sum(`depvar'), .) if `touse'
	qui count if `sumdep' > 1 & `sumdep' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "time periods encountered"
		local multiple multiple
	}

*Delete groups where outcome doesn't vary.

	CountObsGroups `touse' `tvar'
	local n_orig = r(n)
	local nt_orig = r(ng)
	sort `touse' `pvar'
	CountObsGroups `touse' `pvar'
	local ng_orig = r(ng)
	local ng = `ng_orig'
	sort `touse' `tvar'
	tempvar varies rtouse
	qui by `touse' `tvar' : gen byte `varies' = cond(_n == _N, sum(`depvar' != `depvar'[1]), .) if `touse'
	qui by `touse' `tvar' : gen byte `rtouse' = (`varies'[_N] > 0 & `touse')
	qui replace `touse' = `rtouse'
	sort `touse' `tvar'

	CountObsGroups `touse' `tvar'
	local n = r(n)
	local nt = r(ng)

	if `n' < `n_orig' {
	
		if `nt_orig'-`nt' > 1 {
			local s s
		}
		
		di as txt "note: " `nt_orig'-`nt' " time period`s' (" _c
		di as txt `n_orig'-`n' _c 
		di as txt " obs) dropped because of all positive or"
		di as txt "      all negative outcomes"
		local nt_drop	= `nt_orig' - `nt'
		local n_drop	= `n_orig' - `n'
	}

*Check that each depvar varies in at least 1 group.

		capture tsset
		local pvar "`r(panelvar)'"
		local tvar "`r(timevar)'"
		markout `touse' `pvar' `tvar' `depvar' `indepvar', strok
		sort `pvar' `tvar' `touse' 

		if `"`indepvar'"' != "" {
			fvexpand `indepvar'
			local indepvar "`r(varlist)'"
			
			foreach v of local indepvar {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `tvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-time variance"

						if _caller() < 11 {
							local v
						}
						
						else local v o.`v'
					}
				}
				
				local xs `xs' `v'
			}
		}
		
		local indepvar `xs'
}

*******************************************************************************
* Both individual and time effects
*******************************************************************************

else {
	sort `touse' `pvar'
	
*Check outcome varies for at least one individual

	cap by `touse' `pvar' : assert `depvar' == `depvar'[1] if `touse'
	
	if !_rc {
		di as err "Outcome does not vary for any individual"
		exit 2000 
	}
	
	sort `touse' `tvar'
	cap by `touse' `tvar' : assert `depvar' == `depvar'[1] if `touse' 
	
	if !_rc {
		di as err "Outcome does not vary for any time period"
		exit 2000 
	}
	
*Check for multiple positive outcomes accross individuals
	
	tempvar sumdep
	sort `touse' `pvar'
	qui by `touse' `pvar' : gen double `sumdep' = cond(_n == _N, sum(`depvar'), .) if `touse'
	qui count if `sumdep' > 1 & `sumdep' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "groups encountered"
		local multiple multiple
	}
	
	tempvar sumdept
	sort `touse' `tvar'
	qui by `touse' `tvar' : gen double `sumdept' = cond(_n == _N, sum(`depvar'), .) if `touse'
	qui count if `sumdept' > 1 & `sumdept' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "time periods encountered"
		local multiple multiple
	}

*Delete groups where outcome doesn't vary.

	sort `touse' `pvar'
	CountObsGroups `touse' `pvar'
	local n_orig = r(n)
	local ng_orig = r(ng)
	sort `touse' `tvar'
	CountObsGroups `touse' `tvar'
	local nt_orig = r(ng)
	sort `touse' `pvar'
	tempvar varies rtouse
	qui by `touse' `pvar' : gen byte `varies' = cond(_n == _N, sum(`depvar' != `depvar'[1]), .) if `touse'
	qui by `touse' `pvar' : gen byte `rtouse' = (`varies'[_N] > 0 & `touse')
	qui replace `touse' = `rtouse'
	sort `touse' `tvar'
	tempvar variest rtouset
	qui by `touse' `tvar' : gen byte `variest' = cond(_n == _N, sum(`depvar' != `depvar'[1]), .) if `touse'
	qui by `touse' `tvar' : gen byte `rtouset' = (`variest'[_N] > 0 & `touse')
	qui replace `touse' = `rtouset'
	sort `touse' `pvar'
	
	CountObsGroups `touse' `pvar'
	local n = r(n)
	local ng = r(ng)
	sort `touse' `tvar'
	
	CountObsGroups `touse' `tvar'
	local nt = r(ng)

	if `n' < `n_orig' {
		
		if `ng_orig'-`ng' > 1 {
			local sp s
		}
		
		if `nt_orig'-`nt' > 1 {
			local st s
		}
	
		if `ng_orig'-`ng' > 0  & `nt_orig'-`nt' == 0 {
			di as txt "note: " `ng_orig'-`ng' " group`sp' (" _c
			di as txt `n_orig'-`n' _c 
			di as txt " obs) dropped because of all positive or"
			di as txt "      all negative outcomes"
		}
		
		else if `ng_orig'-`ng' == 0  & `nt_orig'-`nt' > 0 {
			di as txt "note: " `nt_orig'-`nt' " time period`st' (" _c
			di as txt `n_orig'-`n' _c 
			di as txt " obs) dropped because of all positive or"
			di as txt "      all negative outcomes"
		}
		
		else {
			di as txt "note: " `ng_orig'-`ng' " group`sp' and " _c
			di as txt `nt_orig'-`nt' " time period`st' (" _c
			di as txt `n_orig'-`n' _c 
			di as txt " obs) dropped because"
			di as txt "      of all positive or all negative outcomes"
		}
		
		local ng_drop	= `ng_orig' - `ng'
		local nt_drop	= `nt_orig' - `nt'
		local n_drop	= `n_orig' - `n'
	}

*Check that each depvar varies in at least 1 group.
		capture tsset
		local pvar "`r(panelvar)'"
		local tvar "`r(timevar)'"
		markout `touse' `pvar' `tvar' `depvar' `indepvar', strok
		sort `pvar' `tvar' `touse' 
		
		if `"`indepvar'"' != "" {
			fvexpand `indepvar'
			local indepvar "`r(varlist)'"
			
			foreach v of local indepvar {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `pvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-group variance"

						if _caller() < 11 {
							local v
						}
						
						else local v o.`v'
					}
				}
				
				local xs `xs' `v'
			}
		}
		
		local indepvar `xs'
		sort `pvar' `tvar' `touse' 
		
		if `"`indepvar'"' != "" {
		
			fvexpand `indepvar'
			local indepvar "`r(varlist)'"

			foreach v of local indepvar {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `tvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-time variance"

						if _caller() < 11 {
							local v
						}
						
						else local v o.`v'
					}
				}
				
				local ts `ts' `v'
			}
		}
		
		local indepvar `ts'
}
	
	ereturn local varlist `indepvar'
	ereturn scalar n = `n'
	ereturn scalar ng = `ng'
	ereturn scalar nt = `nt'
	ereturn scalar n_orig = `n_orig'
	ereturn scalar ng_orig = `ng_orig'
	ereturn scalar nt_orig = `nt_orig'
	
	if `:length local n_drop' {
		ereturn scalar n_drop = `n_drop'
		cap ereturn scalar ng_drop = `ng_drop'
		cap ereturn scalar nt_drop = `nt_drop'
	}
	
end

capture program drop CountObsGroups
program CountObsGroups, rclass 
	args touse group

	tempvar i
	qui count if `touse'
	return scalar n = r(N)
	qui by `touse' `group': gen byte `i' = _n==1 & `touse'
	qui count if `i'
	return scalar ng = r(N)

end
	
*******************************************************************************
*MATA functions
*******************************************************************************
mata: mata clear
mata: mata set matastrict off
mata:

void probitconstantonly(	string	scalar yvar,
							string	scalar touse	)
{
external Y, X

st_view(Y	=., ., yvar,	touse)

X		= J(rows(Y), 1, 1)
XX		= quadcross(X, X)
Xy		= quadcross(X, Y)
XXinv	= invsym(XX)
delta	= XXinv * Xy
delta	= delta'

S 		= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
beta	= optimize(S)
ll_0	= optimize_result_value(S)

st_numscalar("r(ll_0)", ll_0)
}

void probit(	string	scalar yvar,
				string	scalar Xvars,
				string	scalar pvar,
				string	scalar tvar,
				real	scalar n_orig,
				real	scalar fe,
				real	scalar te,
				real	scalar fpc,
				string	scalar touse	)
{
external Y, X
st_view(Y			= ., ., yvar	, touse)
st_view(x2p			= ., ., Xvars	, touse)
st_view(panelvar	= ., ., pvar	, touse)
st_view(timevar		= ., ., tvar	, touse)

k					= cols(x2p)
N					= rows(Y)
info				= panelsetup(panelvar, 1)
T_min				= panelstats(info)[3]
T_max				= panelstats(info)[4]
info				= uniqrows(panelvar)
ng					= rows(info)
FE					= J(N, rows(info), .)

for (i = 1; i<=rows(info); i ++) {
	FE[., i]		= (panelvar :== info[i])
}

info				= uniqrows(timevar)
TE					= J(N, rows(info), .)

for (i=1; i<=rows(info); i++) {
	TE[., i]		= (timevar :== info[i])
}

T_avg				= mean(colsum(FE)')
X					= x2p, fe*FE[., 2::cols(FE)], te*TE[., 2::cols(TE)], J(N, 1, 1)
XX					= quadcross(X, X)
XXinv				= invsym(XX)
XXinvdiag			= diagonal(XXinv)

//Check for additional collinearities between fixed-effects and regressors
for (i=1; i<=rows(XXinvdiag); i++) {
	if (XXinvdiag[i]== 0) {
		X[., i]		= J(rows(X), 1, 0)
	}
}

df_m				= rank(X) - 1
dfs					= N - df_m
XX					= quadcross(X, X)
Xy					= quadcross(X, Y)
XXinv				= invsym(XX)
delta				= XXinv * Xy
delta				= delta'

S 					= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
beta				= optimize(S)
H					= optimize_result_V(S)
ll					= optimize_result_value(S)
rank				= rank(H)
index 				= X * beta'
bmfx				= J(1, k, .)
vate				= J(k, 1, .)
temp				= J(cols(X), k, .)
temp1				= J(rows(uniqrows(panelvar)), 1, uniqrows(timevar))
temp2				= J(rows(uniqrows(timevar)), 1, uniqrows(panelvar))
temp2				= sort(temp2, 1)
info1				= panelsetup(temp2, 1)
info2				= panelsetup(panelvar, 1)

for (i=1; i<=k; i++) {

	if ((min(x2p[.,i]) == 0 | max(x2p[.,i]) == 1) & rows(uniqrows(x2p[.,i])) == 2) {
		X1			= X
		X0			= X
		X1[., i]	= J(rows(X1), 1, 1)
		X0[., i]	= J(rows(X0), 1, 0)
		bmfx[i]		= sum(normal(X1 * beta') - normal(X0 * beta'))/n_orig
		index0		= index - beta[i] * X[., i]
		index1		= index + beta[i] * (1 :- X[., i])
		ates		= normal(index1) - normal(index0)
	}
	
	else {
		bmfx[i]		= beta[i] * sum(normalden(X * beta'))/n_orig
		ates		= beta[i] * normalden(index)
	}
	
	X1temp			= temp1, J(rows(temp1), 1, .)
	X2temp			= timevar, ates
	
	for (p=1; p<=rows(info1); p++) {
		X11temp		= panelsubmatrix(X1temp, p, info1)
		X22temp		= panelsubmatrix(X2temp, p, info2)
	
		for (j=1; j<=rows(X11temp); j++) {
		
			for (l=1; l<=rows(X22temp); l++) {
			
				if (X11temp[j,1] == X22temp[l,1] ) {
					X11temp[j,2] = X22temp[l,2]
				}
			}
		}
		
		X1temp[info1[p,1]::info1[p,2], .]	= X11temp
	}
	
	ates			= X1temp[.,2]'
	ates			= rowshape(ates, ng)'
	ates2			= ates'
	
	if ((min(x2p[.,i]) == 0 | max(x2p[.,i]) == 1) & rows(uniqrows(x2p[.,i])) == 2) {
		x			= colsum(ates') :/ colnonmissing(ates')
		ate			= sum(x)/cols(x)
		temp[.,i]	= colsum(normalden(index1) :* X1 - normalden(index0) :* X0)'/n_orig
	}
	
	else {
		ate			= bmfx[i]
		select		= J(cols(X), 1, 0)
		select[i]	= 1
		if (beta[i] != 0) {
			temp[., i]	= -beta[i] * colsum(index :* normalden(index) :* X)'/n_orig + ate * select / beta[i]
		}
		else {
			temp[., i]	= J(cols(X), 1, 0)
		}
	}
	
	vate[i]			= fpc * (sum(rowsum(ates :- ate) :^ 2) + sum(rowsum(ates2 :- ate) :^ 2) - sum((ates :- ate) :^ 2))/dfs^2
}

Vmfx				= temp' * H * temp :+ vate
b					= beta[1..k]
V					= H[1..k, 1..k]

_makesymmetric(V)
_makesymmetric(Vmfx)
st_matrix("r(b)", b)
st_matrix("r(V)", V)
st_matrix("r(bmfx)", bmfx)
st_matrix("r(Vmfx)", Vmfx)
st_matrix("r(beta)", beta)
st_numscalar("r(k)", k)
st_numscalar("r(df_m)", df_m)
st_numscalar("r(ll)", ll)
st_numscalar("r(rank)", rank)
st_numscalar("r(N)", N)
st_numscalar("r(T_min)", T_min)
st_numscalar("r(T_max)", T_max)
st_numscalar("r(T_avg)", T_avg)
}

void probit_no_sd(	string	scalar yvar,
					string	scalar Xvars,
					string	scalar pvar,
					string	scalar tvar,
					real	scalar n_orig,
					real	scalar fe,
					real	scalar te,
					string	scalar touse	)
{
external Y, X
st_view(Y			= ., ., yvar,	touse)
st_view(x2p			= ., ., Xvars,	touse)
st_view(panelvar	= ., ., pvar,	touse)
st_view(timevar		= ., ., tvar,	touse)

k					= cols(x2p)
N					= rows(Y)
info				= uniqrows(panelvar)
FE					= J(N, rows(info), 0)

for (i = 1; i<=rows(info); i ++) {
	FE[., i]		= (panelvar :== info[i])
}

info				= uniqrows(timevar)
TE					= J(N, rows(info), 0)

for (i=1; i<=rows(info); i++) {
	TE[., i]		= (timevar :== info[i])
}

X					= x2p, fe*FE[., 2::cols(FE)], te*TE[., 2::cols(TE)], J(N, 1, 1)
XX					= quadcross(X, X)
XXinv				= invsym(XX)
XXinvdiag			= diagonal(XXinv)

//Check for additional collinearities between fixed-effects and regressors
for (i=1; i<=rows(XXinvdiag); i++) {
	if (XXinvdiag[i]== 0) {
		X[., i]		= J(rows(X), 1, 0)
	}
}

XX					= quadcross(X, X)
Xy					= quadcross(X, Y)
XXinv				= invsym(XX)
delta				= XXinv * Xy
delta				= delta'

S 					= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
beta				= optimize(S)
bmfx				= J(1, k, .)

for (i=1; i<=k; i++) {

	if ((min(x2p[.,i]) == 0 | max(x2p[.,i]) == 1) & rows(uniqrows(x2p[.,i])) == 2) {
		X1			= X
		X0			= X
		X1[., i]	= J(rows(X1), 1, 1)
		X0[., i]	= J(rows(X0), 1, 0)
		bmfx[i]		= sum(normal(X1 * beta') - normal(X0 * beta'))/n_orig
	}
	
	else {
		bmfx[i]		= beta[i] * sum(normalden(X * beta'))/n_orig
	}
}

b					= beta[1..k]
st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void analytical(	string	scalar yvar,
					string	scalar Xvars,
					string	scalar pvar,
					string 	scalar tvar,
					string	scalar beta1,
					real	scalar n_orig,
					real	scalar fe,
					real	scalar te,
					real	scalar L1,
					real	scalar L2,
					real	scalar L3,
					real	scalar L4,
					string	scalar touse	)
{
external Y, X
beta				= st_matrix(beta1)
st_view(Y			= ., ., yvar	, touse)
st_view(x2p			= ., ., Xvars	, touse)
st_view(panelvar	= ., ., pvar	, touse)
st_view(timevar		= ., ., tvar	, touse)

k					= cols(x2p)
N					= rows(Y)
ng					= rows(uniqrows(panelvar))
FE					= J(N, ng, .)
TNp					= J(ng, 1, .)
info				= panelsetup(panelvar, 1)
T_min				= panelstats(info)[3]
lags				= L1 + L2 + L3 + L4

if (T_min - 1 < lags) {
	display("Number of lags exceeds number of minimum observations in at least one panel")
	exit(error(3300))
}

info1				= uniqrows(panelvar)

for (i = 1; i<=rows(info); i ++) {
	FE[., i]		= (panelvar :== info1[i])
	TNp[i]			= rows(panelsubmatrix(FE, i, info))
}

info				= uniqrows(timevar)
TE					= J(N, rows(info), .)

for (i=1; i<=rows(info); i++) {
	TE[., i]		= (timevar :== info[i])
}

X					= x2p, fe*FE[., 2..cols(FE)], te*TE[., 2..cols(TE)], J(N, 1, 1)
index				= X * beta'
X1					= fe*FE[., 2..cols(FE)], te*TE[., 2..cols(TE)], J(N, 1, 1)
ws					= (normalden(index):^2) :/ (normal(index) :* normal(-index))
XX					= quadcross(X1, ws, X1)
Xy					= quadcross(X1, ws, x2p)
delta				= invsym(XX) * Xy
resx				= x2p - X1 * delta
psi					= (ws :* (Y - normal(index))) :/ normalden(index)
info				= panelsetup(panelvar, 1)
lpsi				= J(rows(psi), 1, 0)
l2psi				= J(rows(psi), 1, 0)
l3psi				= J(rows(psi), 1, 0)
l4psi				= J(rows(psi), 1, 0)

for (i=1; i<=rows(info); i++) {
	P				= panelsubmatrix(psi, i, info)
	TT				= rows(P)
	P1				= P
	P2				= P
	P3				= P
	P4				= P
	if (lags == 1) {
		P1[1]		= 0
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
	}
	else if (lags == 2) {
		P1[1]		= 0
		P2[1::2]	= J(2, 1, 0)
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
		P2[3::rows(P1)]	= P[1::rows(P)-2]
		l2psi[info[i,1]::info[i,2]]	= (TT/(TT - 2)) * P2
	}
	else if (lags == 3) {
		P1[1]		= 0
		P2[1::2]	= J(2, 1, 0)
		P3[1::3]	= J(3, 1, 0)
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
		P2[3::rows(P1)]	= P[1::rows(P)-2]
		l2psi[info[i,1]::info[i,2]]	= (TT/(TT - 2)) * P2
		P3[4::rows(P1)]	= P[1::rows(P)-3]
		l3psi[info[i,1]::info[i,2]]	= (TT/(TT - 3)) * P3
	}
	else if (lags == 4) {
		P1[1]		= 0
		P2[1::2]	= J(2, 1, 0)
		P3[1::3]	= J(3, 1, 0)
		P4[1::4]	= J(4, 1, 0)
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
		P2[3::rows(P1)]	= P[1::rows(P)-2]
		l2psi[info[i,1]::info[i,2]]	= (TT/(TT - 2)) * P2
		P3[4::rows(P1)]	= P[1::rows(P)-3]
		l3psi[info[i,1]::info[i,2]]	= (TT/(TT - 3)) * P3
		P4[5::rows(P1)]	= P[1::rows(P)-4]
		l4psi[info[i,1]::info[i,2]]	= (TT/(TT - 4)) * P4
	}
}

B					= (1/2) * mean(((((index - 2 * L1 * lpsi - 2 * L2 * l2psi - ///
					  2 * L3 * l3psi - 2 * L4 * l4psi) :* ws :* resx)' * FE) :/ (ws' * FE))' :/ TNp)
D					= (1/2) * mean((((index :* ws :* resx)' * TE) :/ (ws' * TE))')
W					= (resx' * (ws :* resx)) / N
bias				= (fe * B + te * D/ng) * invsym(W)
b					= beta[1..k] - bias
offset				= x2p * b'
X					= fe*FE[., 2..cols(FE)], te*TE[., 2..cols(TE)], J(N, 1, 1), offset
XX					= quadcross(X, X)
Xy					= quadcross(X, Y)
XXinv				= invsym(XX)
delta				= XXinv * Xy
delta				= delta'
C					= J(1, cols(X), 0)
k1					= cols(X)
C[k1]				= 1
c					= 1
Cc					= C, c

S 					= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
optimize_init_constraints(S, Cc)
beta				= optimize(S)
index				= X * beta'
ws					= (normalden(index):^2) :/ (normal(index) :* normal(-index))
psi					= (ws :* (Y - normal(index))) :/ normalden(index)
info				= panelsetup(panelvar, 1)
lpsi				= J(rows(psi), 1, 0)
l2psi				= J(rows(psi), 1, 0)
l3psi				= J(rows(psi), 1, 0)
l4psi				= J(rows(psi), 1, 0)

for (i=1; i<=rows(info); i++) {
	P				= panelsubmatrix(psi, i, info)
	TT				= rows(P)
	P1				= P
	P2				= P
	P3				= P
	P4				= P
	if (lags == 1) {
		P1[1]		= 0
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
	}
	else if (lags == 2) {
		P1[1]		= 0
		P2[1::2]	= J(2, 1, 0)
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
		P2[3::rows(P1)]	= P[1::rows(P)-2]
		l2psi[info[i,1]::info[i,2]]	= (TT/(TT - 2)) * P2
	}
	else if (lags == 3) {
		P1[1]		= 0
		P2[1::2]	= J(2, 1, 0)
		P3[1::3]	= J(3, 1, 0)
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
		P2[3::rows(P1)]	= P[1::rows(P)-2]
		l2psi[info[i,1]::info[i,2]]	= (TT/(TT - 2)) * P2
		P3[4::rows(P1)]	= P[1::rows(P)-3]
		l3psi[info[i,1]::info[i,2]]	= (TT/(TT - 3)) * P3
	}
	else if (lags == 4) {
		P1[1]		= 0
		P2[1::2]	= J(2, 1, 0)
		P3[1::3]	= J(3, 1, 0)
		P4[1::4]	= J(4, 1, 0)
		P1[2::rows(P1)]	= P[1::rows(P)-1]
		lpsi [info[i,1]::info[i,2]]	= (TT/(TT - 1)) * P1
		P2[3::rows(P1)]	= P[1::rows(P)-2]
		l2psi[info[i,1]::info[i,2]]	= (TT/(TT - 2)) * P2
		P3[4::rows(P1)]	= P[1::rows(P)-3]
		l3psi[info[i,1]::info[i,2]]	= (TT/(TT - 3)) * P3
		P4[5::rows(P1)]	= P[1::rows(P)-4]
		l4psi[info[i,1]::info[i,2]]	= (TT/(TT - 4)) * P4
	}
}

date				= -index :* normalden(index)
ddate				= (index:^2 :- 1) :* normalden(index)
XX					= quadcross(X1, ws, X1)
Xy					= quadcross(X1, ws, index)
delta				= invsym(XX) * Xy
pindex				= X1 * delta
Xy					= quadcross(X1, ws, (date :/ ws))
delta				= invsym(XX) * Xy
rdate				= (date :/ ws) - X1 * delta
B					= (1/2) * mean((((date :* pindex + ws :* rdate :* (2 * L1 * lpsi + ///
					  2 * L2 * l2psi + 2 * L3 * l3psi + 2 * L4 * l4psi) + ddate)' * FE) :/ (ws' * FE))' :/ TNp)
D					= (1/2) * mean((((date :* pindex + ddate)' * TE) :/ (ws' * TE))')
bias				= fe*B + te*D/ng
bmfx				= b * (sum(normalden(index))/n_orig - bias)

for (i = 1; i <= k; i ++) {

	if ((min(x2p[.,i]) == 0 :| max(x2p[.,i]) == 1) :& rows(uniqrows(x2p[.,i])) == 2) {
		index0		= index - b[i] * x2p[., i]
		index1		= index + b[i] * (1 :- x2p[., i])
		date		= normalden(index1) - normalden(index0)
		ddate		= -(index1 :* normalden(index1) - index0 :* normalden(index0))
		XX			= quadcross(X1, ws, X1)
		Xy			= quadcross(X1, ws, index)
		delta		= invsym(XX) * Xy
		pindex		= X1 * delta
		Xy			= quadcross(X1, ws, (date :/ ws))
		delta		= invsym(XX) * Xy
		rdate		= (date :/ ws) - X1 * delta
		B			= (1/2) * mean((((date :* pindex + ws :* rdate :* (2 * L1 * lpsi + ///
					  2 * L2 * l2psi + 2 * L3 * l3psi + 2 * L4 * l4psi) + ddate)' * FE) :/ (ws' * FE))' :/ TNp)
		D			= (1/2) * mean((((date :* pindex + ddate)' * TE) :/ (ws' * TE))')
		bias		= fe*B + te*D/ng
		bmfx[i]		= sum(normal(index1) - normal(index0))/n_orig - bias
	}
	
	else {
		bmfx[i]		= bmfx[i]
	}
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_ss1(	string scalar beta_fe,
				string scalar betamfx_fe,
				string scalar betas_fe,
				string scalar betasmfx_fe	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

b					= 2*bfe - mean(betas)
bmfx				= 2*bfemfx - mean(betasmfx)

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_ss2(	string scalar beta_fe,
				string scalar betamfx_fe,
				string scalar betas_fe,
				string scalar betasmfx_fe	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

b					= 3*bfe		- mean(betas   [1::2,.]) - mean(betas   [3::4,.])
bmfx				= 3*bfemfx	- mean(betasmfx[1::2,.]) - mean(betasmfx[3::4,.])

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_ss2_temp(	string scalar betas_fe,
						string scalar betasmfx_fe	)
{
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

st_matrix("r(b1)",		mean(betas   [1::2,.]))
st_matrix("r(b2)",		mean(betas   [3::4,.]))
st_matrix("r(bmfx1)",	mean(betasmfx[1::2,.]))
st_matrix("r(bmfx2)",	mean(betasmfx[3::4,.]))
}

void betas_ss2i(	string scalar beta_fe,
					string scalar betamfx_fe,
					string scalar betas_fe,
					string scalar betasmfx_fe,	
					string scalar betas1temp_fe,
					string scalar betasmfx1temp_fe	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)
betas1temp			= st_matrix(betas1temp_fe)
betasmfx1temp		= st_matrix(betasmfx1temp_fe)

b					= 3*bfe		- mean(betas1temp)    - mean(betas   [3::4,.])
bmfx				= 3*bfemfx	- mean(betasmfx1temp) - mean(betasmfx[3::4,.])

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_ss2t(	string scalar beta_fe,
					string scalar betamfx_fe,
					string scalar betas_fe,
					string scalar betasmfx_fe,	
					string scalar betas2temp_fe,
					string scalar betasmfx2temp_fe	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)
betas2temp			= st_matrix(betas2temp_fe)
betasmfx2temp		= st_matrix(betasmfx2temp_fe)

b					= 3*bfe		- mean(betas   [1::2,.]) - mean(betas2temp)
bmfx				= 3*bfemfx	- mean(betasmfx[1::2,.]) - mean(betasmfx2temp) 

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_ss2it(	string scalar beta_fe,
					string scalar betamfx_fe,
					string scalar betas1temp_fe,
					string scalar betasmfx1temp_fe,	
					string scalar betas2temp_fe,
					string scalar betasmfx2temp_fe	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas1temp			= st_matrix(betas1temp_fe)
betasmfx1temp		= st_matrix(betasmfx1temp_fe)
betas2temp			= st_matrix(betas2temp_fe)
betasmfx2temp		= st_matrix(betasmfx2temp_fe)

b					= 3*bfe		- mean(betas1temp)    - mean(betas2temp)
bmfx				= 3*bfemfx	- mean(betasmfx1temp) - mean(betasmfx2temp) 

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_js1(	string	scalar beta_fe,
				string	scalar betamfx_fe,
				string	scalar betas_fe,
				string	scalar betasmfx_fe,	
				string	scalar betastemp_fe,
				string	scalar betasmfxtemp_fe,
				real	scalar ng_orig	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)
betastemp			= st_matrix(betastemp_fe)
betasmfxtemp		= st_matrix(betasmfxtemp_fe)

b					= (ng_orig + 1) * bfe    - (ng_orig - 1) * mean(betastemp)    - mean(betas)
bmfx				= (ng_orig + 1) * bfemfx - (ng_orig - 1) * mean(betasmfxtemp) - mean(betasmfx)

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_js2(	string	scalar beta_fe,
				string	scalar betamfx_fe,
				string	scalar betasp_fe,
				string	scalar betasmfxp_fe,	
				string	scalar betast_fe,
				string	scalar betasmfxt_fe,
				real	scalar ng_orig,
				real	scalar nt_orig	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betasp				= st_matrix(betasp_fe)
betasmfxp			= st_matrix(betasmfxp_fe)
betast				= st_matrix(betast_fe)
betasmfxt			= st_matrix(betasmfxt_fe)

b					= (ng_orig + nt_orig - 1) * bfe    - (ng_orig - 1) * mean(betasp)    - (nt_orig - 1) * mean(betast)
bmfx				= (ng_orig + nt_orig - 1) * bfemfx - (ng_orig - 1) * mean(betasmfxp) - (nt_orig - 1) * mean(betasmfxt)

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void checkdouble(	string	scalar pvar,
					string 	scalar tvar,
					string	scalar touse	)
{
st_view(panelvar	= ., ., pvar	, touse)
st_view(timevar		= ., ., tvar	, touse)

info				= panelsetup(panelvar, 1)
info1				= uniqrows(panelvar)
info2				= uniqrows(timevar)

// Check there is at least one i = t, i = 1,...,N, t = 1,...,T
index				= J(rows(info), 1, .)

for (i=1; i<=rows(info); i++) {
	A				= info1[i] :- info2
	A				= select(A, A :== 0)
	index[i]		= (rows(A) > 0 ? 1 : 0)
}

st_numscalar("r(sum)", sum(index))
st_matrix("r(index)", select(info1, index))
}

void betas_double(	string	scalar beta_fe,
					string	scalar betamfx_fe,
					string	scalar betas_fe,
					string	scalar betasmfx_fe,	
					real	scalar ndouble	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

b					= (ndouble) * bfe    - (ndouble - 1) * mean(betas)
bmfx				= (ndouble) * bfemfx - (ndouble - 1) * mean(betasmfx)

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void llnprobit(todo, b, llj, g, H)
{
external Y, X
real colvector	pm
real colvector	xb
real colvector	lj
real colvector	dllj
real colvector	d2llj
real scalar	dim
real scalar	nobs

nobs	= rows(Y)
dim		= cols(X)

if (nobs != rows(X) | dim != cols(b)) {
	_error(3200)
}

pm		= 2 * (Y :!= 0) :- 1
xb		= X * b'
lj		= normal(pm :* xb)
llj		= ln(lj)

if (todo == 0 | missing(llj)) return

dllj	= pm :* normalden(xb) :/ lj

if (missing(dllj)) {
	llj = .
	return
}

g		= dllj :* X

if (todo == 1) return

d2llj	= dllj :* (dllj + xb)

if (missing(d2llj)) {
	llj = .
	return
}

H		= -cross(X, d2llj, X)
}
end
