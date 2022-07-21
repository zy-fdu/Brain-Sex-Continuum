# Brain-Sex-Continuum (version 1.0)

Key words: brain sex continuum

If this toolbox is used in your work, please cite the reference, namely Zhang Y, Luo Q, Huang C, et al. 2021. The Human Brain Is Best Described as Being on a Female/Male Continuum: Evidence from a Neuroimaging Connectivity Study. Cereb Cortex. bhaa 408.

---

The toolbox was last updated by Yi Zhang on 19/July/2022.
If you have any problems, please contact Dr. Yi Zhang through yizhang_fd@fudan.edu.cn.

---------------------------------
This toolbox contains function for computing the brain sex continuum.

computeBSC.m is the main function for computing the brain sex continuum.<br> 
*_regcoef.mat are coefficients derived from UKB and HCP for regressing out age to its third order term, the intercept term is also included.<br>
*_SVMcoef.mat are trained coefficients of the SVM classifier for computing the brain sex continuum.
The toolbox runs under MATLAB circumstance.

---------------------------------

# Input of the toolbox
    
	FCmatrix:
	Matrix with size of [94*94*n_subject(s)] or [264*264*n_subject(s)]. Unfortunately, the program only support FC based on AAL2(cerebral regions) or Power264 parcellation currently.
        FCmatrix should NOT be Fisher-Z transformed.
        
	age:
	Vector with size of [n_subject(s)*1], indicating age of the subject(s). Young subject(s) (subject(s) younger than around 20 y.o.) are not recommended for computing BSC through this program (though feasible).

	UseEmpiricalRegCoef:
	1 = use, 0 = not use.
	Indicator of whether using regression coefficients from UKB and HCP for regressing out age-related terms from FC. If used, UKB coefficients will be used for regressing subjects older than 45, and HCP coefficients will be used for subjects younger than 45. Require at least 10 subjects input for not using empirical coefficient. 
   
   
    
# Output of the toolbox (BSC)
	The brain sex continuum of the input subject(s).
