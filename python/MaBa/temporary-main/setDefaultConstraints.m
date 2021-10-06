function obj = setDefaultConstraints(obj, NumAssets)
%setDefaultConstraints - Set up portfolio constraints with non-negative weights that must sum to 1.
%
%   obj = setDefaultConstraints(obj);
%   obj = setDefaultConstraints(obj, NumAssets);
%
%	obj = obj.setDefaultConstraints(NumAssets);
%
% Inputs:
%	obj - A Portfolio object [Portfolio].
%
% Optional Inputs:
%	NumAssets - Number of assets in portfolio [scalar].
%
% Outputs:
%	obj - Updated Portfolio object [Portfolio].
%
% Notes:
%	1) A "default" portfolio set has LowerBound = 0, BoundType='Simple' and LowerBudget = UpperBudget = 1
%       so that a portfolio Port must satisfy
%			sum(Port) = 1
%		with
%			Port >= 0 .
%	2) The default value for NumAssets is 1.
%	3) This method does not modify any existing constraints in a Portfolio object other than the
%      bound, boundType and budget constraints. If an UpperBound constraint exists, it is cleared
%      and set to [].
%	4) NumAssets cannot be used to change the dimension of a Portfolio object.
%
% See also Portfolio, setBounds, setBudget.

% Copyright 2010-2018 The MathWorks, Inc.

if ~checkobject(obj)
    error(message('finance:Portfolio:setDefaultConstraints:InvalidInputObject'));
end

try
    
    if nargin == 1
        parameters = { 'Budget', 'LowerBound', 'BoundType'};
        values = { 1, 0, obj.BoundTypeCategory(1)};
    end
    
    if nargin == 2
        parameters = { 'Budget', 'LowerBound', 'BoundType', 'NumAssets' };
        values = { 1, 0, obj.BoundTypeCategory(1), NumAssets };
    end
    
    obj.UpperBound = [];
    
    obj = parsearguments(obj, parameters, values);
    obj = checkarguments(obj);
    
catch errState
    
    msg = message('finance:Portfolio:setDefaultConstraints:IndeterminateSpecification');
	newState = MException(msg.Identifier, msg.getString);
    newState = addCause(newState, errState);
    newState.throwAsCaller();
    
end
