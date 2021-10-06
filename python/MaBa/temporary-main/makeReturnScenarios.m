function obj = makeReturnScenarios(obj, RandomSeedForReturns, ...
            ScenarioSetting, nScenarios)
        
if ~checkobject(obj)
    error('Invalid input object.');
end

if isempty(obj.AssetMean)
    error('Need to set asset mean.');
end

rng(RandomSeedForReturns)

switch lower(ScenarioSetting)
    case {'flex uniform', 'flexuniform'}
        if isempty(obj.UniformMinimumReturn) || isempty(obj.UniformMaximumReturn)
            error('Need to set uniform min and max returns.');
        end
        objScenarios = LopsidedUniformDistribution(obj.UniformMinimumReturn, ...
            obj.UniformMaximumReturn, obj.AssetMean);
        
    case {'flex normal', 'flexnormal'}
        if isempty(obj.bolUncorrelStdErr) || isempty(obj.AssetStdErr)
            error('Need to set asset standard errors and correlated standard errors flag.');
        end
        if obj.bolUncorrelStdErr
            objScenarios = NormalDistributionForSimulations(obj.AssetMean, obj.AssetStdErr);
        else
            if isempty(obj.AssetStdErrCorrelMatrix)
                error('Need to set asset standard errors correlation matrix.');
            end
            objScenarios = CorrelNormalDistributionForSimulations(obj.AssetMean, ...
                obj.AssetStdErr, obj.AssetStdErrCorrelMatrix);
        end
    case {'flex skew normal', 'flexskewnormal'}
        if isempty(obj.bolUncorrelStdErr) || isempty(obj.AssetStdErr) || ...
                isempty(obj.AssetStdErrSkew) || isempty(obj.AssetStdErrKurt)
            error('Need to set asset standard errors moments and correlated standard errors flag.');
        end
        if obj.bolUncorrelStdErr
            objScenarios = PearsonDistributionForSimulations(obj.AssetMean, ...
                obj.AssetStdErr, obj.AssetStdErrSkew, obj.AssetStdErrKurt);
        else
            if isempty(obj.AssetStdErrCorrelMatrix)
                error('Need to set asset standard errors correlation matrix.');
            end
            objScenarios = CorrelPearsonDistributionForSimulations(obj.AssetMean, ...
                obj.AssetStdErr, obj.AssetStdErrSkew, obj.AssetStdErrKurt, ...
                obj.AssetStdErrCorrelMatrix);
        end
    otherwise
        error('Error. Invalid scenario setting');
end
objScenarios = simulateValues(objScenarios, RandomSeedForReturns, nScenarios);
if obj.bolCorrectMeanAndStd
    objScenarios = objScenarios.correctSimulatedValuesForMeanAndStd;
end

obj.objScenarios = objScenarios;
end

