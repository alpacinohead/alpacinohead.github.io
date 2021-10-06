classdef PortfolioMayabay < Portfolio
    
    % Convention on vector/matrix orientation.  Try to arrange all
    % vectors/matrices so that (if they do have a least 1 dimension of size
    % NumAssets) it is the first dimension
    properties (SetAccess = 'public', GetAccess = 'public', Hidden = false)
        AssetStdErr
        bolUncorrelStdErr = true; % Default to uncorrelated standard errors
        AssetStdErrCorrelMatrix
        % flex uniform settings
        UniformMinimumReturn
        UniformMaximumReturn
        % flex skew normal settings
        AssetStdErrSkew
        AssetStdErrKurt
        % Scenarios
        bolCorrectMeanAndStd 
        
        % Starting points
        StepSizeForStartPoints
        MaxBatchSizeForStartPoints = 1e7;
        
        % Optimisation Settings
        ScoringOption
        MeanStdErrWeights
        PercentileForScore
        TrackingCorrel
        
        % Wait bar
        AppDesUiProgressDlg
        bolShowWaitBar
        
%     end
%     
%     properties (SetAccess = 'public', GetAccess = 'public', Hidden = true)
        objScenarios
        AdjLowerBound
        AdjUpperBound
        StartPointsWeight % nAssets x nStartPoints
        nStartPoints
        StartPointsAtTargets
        bolFoundStartPointsAtTargets
    end
    
    methods (Access = 'public', Static = false, Hidden = false)
		
		% constructor method
		
        function obj = PortfolioMayabay(varargin)
            %PortfolioMayabay - Construct PortfolioMayabay object.
			
			if nargin < 1 || isempty(varargin)
				% no argument list
				% create a PortfolioMayabay object from scratch and put into obj
				% return object with empty properties
				return
			elseif isa(varargin{1}, 'PortfolioMayabay')
				% first argument is a PortfolioMayabay object so put into obj
				% put remaining argument list into the variable arglist
				obj = varargin{1};
				if ~isscalar(obj)
					error('Non scalar PortfolioMayabay object.');
				end
				if nargin > 1
					arglist = varargin(2:end);
				else
					return
				end
			else
				% argument list is just parameter-value pairs
				% make sure that no PortfolioMayabay object in the argument list after the first argument
				% if ok, put argument list into the variable arglist
				arglist = varargin;
				for i = 1:numel(arglist)
					if isa(arglist{i}, 'PortfolioMayabay')
						error('Improper object input.');
					end
				end
			end
			
			% parse arguments
			obj = parseArgumentsPortfolioMayabay(obj, arglist);
			
			% check arguments
			obj = checkArgumentsPortfolioMayabay(obj);
			
        end
		
		% get methods
        
        function [AssetStdErr, AssetStdErrCorrelMatrix] = ...
                getAssetStdErrValues(obj)
			if ~checkobject(obj)
				error('Invalid input object.');
			end
           AssetStdErr = obj.AssetStdErr; 
           AssetStdErrCorrelMatrix = obj.AssetStdErrCorrelMatrix; 
        end
        
        function bolUncorrelStdErr = getbolUncorrelStdErr(obj)
			if ~checkobject(obj)
				error('Invalid input object.');
			end
           bolUncorrelStdErr = obj.bolUncorrelStdErr;
        end
		
		% set methods
        
        obj = setPropertiesWithNameValuePairs(obj, varargin);
        obj = setPropertiesFromMayabayStructure(obj, stuMayabay);
        Data = createDataStructFromMayabayTemplateFile(obj, ...
            ExcelFile);
        Data = subSetMayabayStructure(obj, stuMayabay, catAssetsToUse);
        
        % Start points calculations.  These are the points from which
        % optimisation begins (the output can vary based on starting point
        % because of non-convex surface)
        obj = calculateBoundsForStartPoints(obj);
        obj = calculateStartPoints(obj);
        obj = calculateStartPointsFixedNumber(obj, RandomSeedForStartWeights, ...
            nStartPoints);
        
        % Pre-optimisation set up methods
        StartWeightAtTarget = optimiseToClosestPoints(obj, StartPointsWeight, ...
            bolAppDesUiProgressDlg, AppDesUiProgressDlg, NonLinearConstraints)
        obj = findClosetPortfoliosAtTargets(obj, TargetRisk, AppDesUiProgressDlg);
        obj = makeReturnScenarios(obj, RandomSeedForReturns, ...
            ScenarioSetting, nScenarios);
        
        % Main optimisation run
        [OptimisedPortfolioWeight, MaxScoreOfFeasibleOptimisedWeights] = ...
            optimisePortfolioScore(obj, TargetRisk, AppDesUiProgressDlg);
        
        % Useful other methods
        PortfolioTrackingError = estimatePortTrackingError(obj, pwgt, ...
            TrackingPort, bolPairUpPortfolios);
        [OptimisedPortfolioWeight, OptimisedCorrel] = ...
            maximiseCorrelationAtTargetRisk(obj, TargetRisk);
        obj = addIncomeConstraint(obj, IncomeByAssetClass, TargetIncome);
        pwgt = estimateFrontierByRiskForceRisk(obj, TargetRisks);
        [pwgt, CombinationWeights] = interpolateBetweenPortfolios(obj, PortfoliosForInter, TargetRisk)
    end
	
	% hidden methods
    
    methods (Access = 'public', Static = false, Hidden = true)
		
		% utility methods
		
		function objstate = checkobject(obj)
			if isa(obj,'PortfolioMayabay') && isscalar(obj)
				objstate = true;
			else
				objstate = false;
			end
        end
		obj = parseArgumentsPortfolioMayabay(obj, parameters, values);	% method to process argument lists
		obj = checkArgumentsPortfolioMayabay(obj);
        
    end
end

