function BSC = computeBSC(FCmatrix,age,UseEmpiricalRegCoef)

%%%%%%%%%%%%%  function for computing the Brain Sex Continuum %%%%%%%%%%%%%
%                                                                         %
% subject to: The Human Brain Is Best Described as Being on a Female/Male %
% Continuum: Evidence from a Neuroimaging Connectivity Study              %
%                                                                         %
% Zhang et al. 2021, doi: 10.1093/cercor/bhaa408                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% FCmatrix                                                                %
% Matrix with size of [94*94*n_subject(s)] or [264*264*n_subject(s)].     %
% Unfortunately, the program only support FC based on AAL2 or Power264    %
% parcellation currently.                                                 %
% FCmatrix should NOT be Fisher-Z transformed.                            %
%                                                                         %
% age                                                                     %
% Vector with size of [n_subject(s)*1], indicating age of the subject(s). %
% Young subject(s) (subject(s) younger than around 20 y.o.) would not be  %
% suitable for computing BSC through this program (though feasible).      %
%                                                                         %
% UseEmpiricalRegCoef                                                     %
% 1 = use, 0 = not use.                                                   %
% Indicator of whether using regression coefficients from UKB and HCP for %
% regressing out age-related terms from FC.                               %
% If used, UKB coefficients will be used for regressing subjects older    %
% than 45, and HCP coefficients will be used for subjects younger than 45.%
% Require at least 10 subjects input for not using empirical coefficient. %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% BSC                                                                     %
% The brain sex continuum of the input subject(s).                        %
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%% Last Updated by Yi Zhang 19/July/2022 %%%%%%%%%%%%%%%%%%%


% basic information
[n_ROI,~,n_subject] = size(FCmatrix);

% loading regressing and SVM coefficients
if n_subject<=10 && UseEmpiricalRegCoef == 0
    error('Too few subjects, inappropriate for regression.\n')
end
if n_ROI == 94
    load('aal2_SVMcoef.mat')
    if UseEmpiricalRegCoef == 1
        load('aal2_regcoef.mat')
    end
else if n_ROI == 264
        load('power264_SVMcoef.mat')
        if UseEmpiricalRegCoef == 1
            load('power264_regcoef.mat')
        end
else
    error('Current version only support compute BSC based on AAL2 and Power264.\n')
end
end

% vectorize FC matrix
for i_subject = 1:n_subject
    FC_temp = [];
    for i_ROI = 1:n_ROI
        FC_temp = [FC_temp,FCmatrix(i_ROI,i_ROI+1:n_ROI,i_subject)];
    end
    FCvec(i_subject,:) = FC_temp;
end
FCvec = 0.5*log((1+FCvec)./(1-FCvec));

% regressing out age terms
if size(age,2)~=1
    age = age';
end
age_term = [age,age.^2,age.^3];
if UseEmpiricalRegCoef == 0
    for i_ROI = 1:(n_ROI*(n_ROI-1)/2)
        glmstruct = fitglm(age_term,FCvec(:,i_ROI));
        b = glmstruct.Coefficients.Estimate;
        FC_regressed(:,i_ROI) = FCvec(:,i_ROI)-[ones(n_subject,1),age_term]*b;
    end
else
    FC_regressed(age>=45,:) = FCvec(age>=45,:) - [ones(sum(age>=45),1),age_term(age>=45,:)]*b_UKB;
    FC_regressed(age<45,:) = FCvec(age<45,:) - [ones(sum(age<45),1),age_term(age<45,:)]*b_HCP;
end

% compute BSC
clfscore = [ones(n_subject,1) FC_regressed/12]*SVMbeta;
BSC(:,3) = normcdf(clfscore);