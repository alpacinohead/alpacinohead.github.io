%% Example that uses the Matlab Portfolio class
% You use a "class" to make an "object".  A "class" is a template.  When 
% you create on object of that class (i.e., using that template) 
% you assign specific values.  For example, you could have a class for a
% car in a game (which outlines a generic template).  When you create of
% object of that class, you specify specific value, e.g., what colour is
% the car, what's its top speed.
% Classes have both properties (e.g., colour, top speed) and methods - they
% can do things (e.g., turn left, turn right, speed up, slow down)

%%
% This creates the object.  In this case, it will be a blank (empty) object
% because we haven't provided any inputs
% You can right click on the word "Portfolio" and then go to "Open
% Portfolio" to see the code for that class. 
obj = Portfolio;

% this sets a property of the object, in this case, the names of the assets
% to be used
obj = obj.setAssetList('Cash', 'Global Fixed Income', 'UK Equity', ...
    'Int Equity');
AssetExpMeanRet = [0.001, 0.005, 0.05, 0.06];
AssetExpStdRet = [0.01, 0.04, 0.12, 0.14];
AssetExpCorrel = [1 -0.1 0.01 0.02; -0.1 1 0.1 0.05; 0.01 0.1 1 .8; 0.02 .05 0.8 1];
% the portfolio object requires a covariance matrix rather than
% volatilities and correlations.  this function converts the latters to the
% former
AssetExpCovar = corr2cov(AssetExpStdRet, AssetExpCorrel);
% this sets the expected returns and covariances for the assets
obj = obj.setAssetMoments(AssetExpMeanRet, AssetExpCovar);
% set default constraints.  Asset min weight = 0, asset max weight = 1,
% total portfolio weight = 1
obj = setDefaultConstraints(obj);
NumPorts = 20;
% this creates 20 portfolios along the efficient frontier.  the first point
% is the minimum volatility portfolio.
pwgt = estimateFrontier(obj, NumPorts);
% once we have the portfolio weights, we can calculate the return and
% volatility of those portfolios.  Note that we calculate all returns and
% volatilities in one set - we don't need to do this for each portfolio
% individually.  
[prsk, pret] = estimatePortMoments(obj, pwgt);
% we can also plot the frontier using the in-built functionality.  
[prsk2, pret2] = plotFrontier(obj);