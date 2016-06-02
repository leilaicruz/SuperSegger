function [classificationTreePruned, treeFun] = trainTree(X,Y)
% trainTree : trains a classification tree.
%  returns a trained classifier and its validation accuracy.
%  This code recreates the classification model trained in
%  Classification Learner app.
%
%   Input:
%       X : predictive variables (21)
%       Y : response variables
%
%   Output:
%       classificationTreePruned: a struct containing pruned trained classifier.
%        The struct contains various fields with information about the
%        trained classifier.
%
%       treeFun : the function used for obtaining the scores with this classifier. 
%
% Auto-generated by MATLAB on 24-May-2016 23:47:52
% University of Washington, 2016
% This file is part of SuperSegger.

treeFun = @treeScore;
trainingData = [Y,X];
num_var = size(trainingData,2);


area = X(:,11);

% Convert input to table
inputTable = table(trainingData);
inputTable.Properties.VariableNames = {'column'};

names = {};
for i = 1 : num_var
names{end+1} = [inputTable.Properties.VariableNames{1},'_',num2str(i)];
end

% Split matrices in the input table into vectors
inputTable = [inputTable(:,setdiff(inputTable.Properties.VariableNames, {'column'})), array2table(table2array(inputTable(:,{'column'})), 'VariableNames', names)];
%{'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9', 'column_10', 'column_11', 'column_12', 'column_13', 'column_14', 'column_15', 'column_16', 'column_17', 'column_18', 'column_19', 'column_20', 'column_21', 'column_22'})];


% Extract predictors and response
% This code processes the data into the right shape for training the
% classifier.
predictorNames = names(2:end) ; %{'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9', 'column_10', 'column_11', 'column_12', 'column_13', 'column_14', 'column_15', 'column_16', 'column_17', 'column_18', 'column_19', 'column_20', 'column_21', 'column_22'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_1;

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
classificationTree = fitctree(...
    predictors, ...
    response, ...
    'SplitCriterion', 'gdi', ...
    'MaxNumSplits', 100, ...
    'Surrogate', 'off', ...
    'ClassNames', [0; 1]);

trainedClassifier.ClassificationTree = classificationTree;
convertMatrixToTableFcn = @(x) table(x, 'VariableNames', {'column'});
splitMatricesInTableFcn = @(t) [t(:,setdiff(t.Properties.VariableNames, {'column'})), array2table(table2array(t(:,{'column'})), 'VariableNames', predictorNames)];
extractPredictorsFromTableFcn = @(t) t(:, predictorNames);
predictorExtractionFcn = @(x) extractPredictorsFromTableFcn(splitMatricesInTableFcn(convertMatrixToTableFcn(x)));
treePredictFcn = @(x) predict(classificationTree, x);
trainedClassifier.predictFcn = @(x) treePredictFcn(predictorExtractionFcn(x));

%classificationTreePruned = trainedClassifier.ClassificationTree ;
% prune the tree
rng(1); % For reproducibility
m = max(classificationTree.PruneList) - 1;
[E,~,~,bestLevel] = cvloss(classificationTree,'SubTrees',0:m,'KFold',5);
classificationTreePruned = prune(classificationTree,'Level',bestLevel);
figure(1);
view(classificationTreePruned,'Mode','graph')

% Perform cross-validation
partitionedModel = crossval(classificationTreePruned, 'KFold', 5);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

% Compute validation predictions and scores
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

disp(['Training classification tree done with accuracy : ',num2str(validationAccuracy)]);


