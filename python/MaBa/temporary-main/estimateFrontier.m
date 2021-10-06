function [pwgt, pbuy, psell] = estimateFrontier(obj, NumPorts)
%estimateFrontier - Estimate specified number of optimal portfolios over entire efficient frontier.
%
%	[pwgt, pbuy, psell] = estimateFrontier(obj, NumPorts);
%
%	[pwgt, pbuy, psell] = obj.estimateFrontier(NumPorts)
%
% Inputs:
%	obj - A Portfolio object [Portfolio].
%
% Optional Inputs:
%	NumPorts - Number of points to obtain on the efficient frontier with default value from
%       obj.defaultNumPorts [scalar integer].
%
% Outputs:
%	pwgt - Optimal portfolios on the efficient frontier with specified number of portfolios spaced
%		equally from minimum to maximum portfolio return [NumAssets x NumPorts matrix].
%	pbuy - Purchases relative to an initial portfolio for optimal portfolios on the efficient
%		frontier [NumAssets x NumPorts matrix].
%	psell - Sales relative to an initial portfolio for optimal portfolios on the efficient
%		frontier [NumAssets x NumPorts matrix].
%
% Comments:
%	1) If no value is specified for NumPorts, the default value is obtained from the hidden
%       property defaultNumPorts (current default value is 10). If NumPorts = 1, this method
%       returns the portfolio specified by the hidden property defaultFrontierLimit (current
%       default value is 'min').
%	2) If no initial portfolio is specified in obj.InitPort, it is assumed to be 0 so that pbuy =
%		max(0, pwgt) and psell = max(0, -pwgt).
%
% See also estimateFrontierByReturn, estimateFrontierByRisk, estimateFrontierLimits.

% Copyright 2010-2018 The MathWorks, Inc.

% check arguments

if ~checkobject(obj) || isempty(obj)
	error(message('finance:Portfolio:estimateFrontier:InvalidInputObject'));
end

if nargin < 2 || isempty(NumPorts)
	NumPorts = obj.defaultNumPorts;				% default value for number of portfolios
end

if ~internal.finance.naturalcheck(NumPorts)
	error(message('finance:Portfolio:estimateFrontier:InvalidNumPorts'));
end

% estimate portfolios on efficient frontier

if hasIntegerConstraints(obj)
    pwgt = frontierMixedInteger(obj, NumPorts);
else
    pwgt = frontierContinuous(obj, NumPorts);
end

% compute purchases and sales

if nargout > 1
	if isempty(obj.InitPort)
		pbuy = bsxfun(@max, 0, pwgt);
		psell = bsxfun(@max, 0, -pwgt);
	else
		pbuy = bsxfun(@max, 0, bsxfun(@minus, pwgt, obj.InitPort));
		psell = bsxfun(@max, 0, bsxfun(@minus, obj.InitPort, pwgt));
	end
end


function pwgt = frontierMixedInteger(obj, NumPorts)
% Solves frontier by return problems to find (risk, retn) points on EF.
ProbStruct = buildMixedIntegerProblem(obj);
if NumPorts == 1
	% default behavior is to return a minimum-risk portfolio based on the hidden property
	% defaultFrontierLimit, to obtain maximum-return portfolio, change the property to 'max'
    if strcmpi(obj.defaultFrontierLimit, 'min')
        pwgt = mv_int_min_risk(obj, ProbStruct);
    else
        pwgt = mv_int_max_return(obj, ProbStruct);
    end
elseif NumPorts == 2
	pwgt = mv_int_min_risk(obj, ProbStruct);
    pwgt = [pwgt mv_int_max_return(obj, ProbStruct)];
else
    pwgtLimits = mv_int_min_risk(obj, ProbStruct);
    pwgtLimits = [pwgtLimits mv_int_max_return(obj, ProbStruct)];
    pret = estimatePortReturn(obj, pwgtLimits);
    retn = linspace(pret(1), pret(2), NumPorts); 
    retnInBetween = retn(2:end-1);
    pwgt = zeros(obj.getNumAssets(), numel(retnInBetween));
    for i=1:numel(retnInBetween)
       pwgt(:, i) = mv_int_by_return(obj, ProbStruct, retnInBetween(i));
    end
    pwgt = [pwgtLimits(:, 1), pwgt, pwgtLimits(:, 2)];
end


function pwgt = frontierContinuous(obj, NumPorts)
if NumPorts == 1
	% default behavior is to return a minimum-risk portfolio based on the hidden property
	%	defaultFrontierLimit, to obtain maximum-return portfolio, change the property to 'max'
	pwgt = obj.estimateFrontierLimits(obj.defaultFrontierLimit);
elseif NumPorts == 2
	pwgt = obj.estimateFrontierLimits;
else
	% transform problem
	
	[A, b, f0, f, H, g, d] = mv_optim_transform(obj);

	if ~isempty(obj.TrackingError)		
		[gT0, gT] = mv_transform_te(obj, d);

		% get upper and lower bounds for efficient portfolio returns

		pmin = mv_optim_min_risk_te(obj.NumAssets, A, b, f0, f, H, g, d, gT0, gT, ...
			obj.solverTypeNL, obj.solverOptionsNL, obj.enforcePareto);
		
		pmax = mv_optim_max_return_te(obj.NumAssets, A, b, f0, f, H, g, d, gT0, gT, ...
			obj.solverTypeNL, obj.solverOptionsNL, obj.enforcePareto);

		pret = obj.estimatePortReturn([pmin, pmax]);

		r = linspace(pret(1), pret(2), NumPorts);

		% solve for interior frontier points

		pwgt = mv_optim_by_return_te(r(2:end-1), obj.NumAssets, A, b, f0, f, H, g, d, ...
			gT0, gT, obj.solverTypeNL, obj.solverOptionsNL);
	else
		% get upper and lower bounds for efficient portfolio returns

		pmin = mv_optim_min_risk(obj.NumAssets, A, b, f0, f, H, g, d, ...
			obj.solverType, obj.solverOptions, obj.enforcePareto);
		pmax = mv_optim_max_return(obj.NumAssets, A, b, f0, f, H, g, d, obj.solverOptionsLP, ...
			obj.solverType, obj.solverOptions, obj.enforcePareto);	

		pret = obj.estimatePortReturn([pmin, pmax]);

		r = linspace(pret(1), pret(2), NumPorts);

		% solve for interior frontier points

		pwgt = mv_optim_by_return(r(2:end-1), obj.NumAssets, A, b, f0, f, H, g, d, ...
			obj.solverType, obj.solverOptions);
	end
	
	pwgt = [ pmin, pwgt, pmax ];

end
