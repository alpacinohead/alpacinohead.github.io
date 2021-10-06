clear

%%
AssetMean = [0.01, 0.02, 0.03];
AssetVol = [0.05, 0.08, 0.12];
CorrelMatrix = [1, 0.5, 0.3; 0.5, 1, 0.7; 0.3, 0.7, 1];
LowerBound = [0, 0, 0.05];
UpperBound = [0.25, 0.75, 1];

%%
objPortfolioMayabay = Portfolio('AssetMean', AssetMean, ...
    'AssetCovar', corr2cov(AssetVol, CorrelMatrix), ...    'LowerBound', LowerBound, 'UpperBound', UpperBound);
NumPorts = 20;
pwgt = estimateFrontier(objPortfolioMayabay, NumPorts);
[prsk, pret] = estimatePortMoments(objPortfolioMayabay, pwgt);

%%
objPortfolioMayabay = objPortfolioMayabay.setPropertiesWithNameValuePairs( ...
    'StepSizeForStartPoints', 0.025, 'AEquality', ones(1, ...
    objPortfolioMayabay.NumAssets), 'bEquality', 1);
objPortfolioMayabay = calculateBoundsForStartPoints(objPortfolioMayabay);
objPortfolioMayabay = calculateStartPoints(objPortfolioMayabay);
TargetRisk = 0.09;
objPortfolioMayabay = findClosetPortfoliosAtTargets(objPortfolioMayabay, TargetRisk);
[prsk2, pret2] = estimatePortMoments(objPortfolioMayabay, objPortfolioMayabay.StartPointsAtTargets);

%%
AssetStdErr = [0.005, 0.03, 0.05];
AssetStdErrSkew = [0, -0.5, -1];
AssetStdErrKurt = [3.5, 3, 4];
RandomSeedForReturns = 10;
nScenarios = 10000;
ScenarioSetting = 'Flex Skew Normal';
objPortfolioMayabay = objPortfolioMayabay.setPropertiesWithNameValuePairs( ...
    'AssetStdErr', AssetStdErr, 'AssetStdErrSkew', AssetStdErrSkew, ...
    'AssetStdErrKurt', AssetStdErrKurt, 'bolCorrectMeanAndStd', true);
objPortfolioMayabay = makeReturnScenarios(objPortfolioMayabay, RandomSeedForReturns, ...
    ScenarioSetting, nScenarios);
%%
AssetReturnsByScenario = objPortfolioMayabay.objScenarios.SimulatedValues;
PortfolioWeights = objPortfolioMayabay.StartPointsAtTargets;
MeanStdErrWeights = [1, -2];
PortfolioScore = calculatePortfolioScoreMeanStdErr(AssetReturnsByScenario, ...
    PortfolioWeights, MeanStdErrWeights);
PercentileForScore = 0.05;
PortfolioScorePerc = calculatePortfolioScorePercentile(AssetReturnsByScenario, ...
    PortfolioWeights, PercentileForScore);
%%
fig = uifigure;
d = uiprogressdlg(fig);
objPortfolioMayabay = objPortfolioMayabay.setPropertiesWithNameValuePairs( ...
    'ScoringOption', 'MeanStdErr', 'MeanStdErrWeights', [1, -2]);
[OptimisedPortfolioWeight, MaxScoreOfFeasibleOptimisedWeights] = ...
    optimisePortfolioScore(objPortfolioMayabay, TargetRisk, d);

%%
pwgtNoTrack = estimateFrontierByRisk(objPortfolioMayabay, ...
    TargetRisk);
objPortfolioMayabay = objPortfolioMayabay.setPropertiesWithNameValuePairs( ...
    'TrackingError', 0.01, 'TrackingPort', [0.1, 0.5, 0.4]);
pwgtNoTrack(:, 2) = estimateFrontierByRisk(objPortfolioMayabay, ...
    TargetRisk);
pwgtNoTrack(:, 3) = ...
    optimisePortfolioScore(objPortfolioMayabay, TargetRisk);
[prsk3, pret3] = estimatePortMoments(objPortfolioMayabay, pwgtNoTrack);

PortfolioTrackingError = estimatePortTrackingError(objPortfolioMayabay, ...
    pwgtNoTrack);

%%
objPortfolioMayabay.TrackingError = [];
CorrelTargetRisk = 0.105;
[pwgtMaxCorrel, Correl] = objPortfolioMayabay.maximiseCorrelationAtTargetRisk(CorrelTargetRisk);
