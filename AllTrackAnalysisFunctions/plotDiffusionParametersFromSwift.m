function [minv, maxv, gaussDat, kernelDat] = plotDiffusionParametersFromSwift(Axes, binNumbers, SaveStructure, property, lengthUnit, filterIDs, performFit)
%Function to plot the respective jump distances as a histogram in the track
%analysis window.
%Input: Axes - axes object to plot into
       %SaveStructure - structured array that contains the jump distances
       %property - defines if either D or MSD
       %filterIDs - if we use a filter we can provide the ids to search for
       %here
       %performFit - will try to perform several fits to find a matching
       %distribution
       
       %% Get the data of choice
       data = SaveStructure.SwiftParams.(property);
       
       %% Apply the filter if necessary
       if size(filterIDs,1)>0
           ids = data(:,1);
           ids = cell2mat(ids);
           idx = find(ids == filterIDs);
           filteredData = {};
           for i = 1:size(idx)
               filteredData(:,i) = data(idx,:);
           end
           data = filteredData;
       end
       %% Unpack the cell array
       data = cell2mat(data(:,2));
       
       %% Plot the data
       minv = min(data(:,2));
       maxv = max(data(:,2));
       edges = linspace(minv, maxv, binNumbers);
       histogram(Axes, data, edges)
       xlim(Axes, [minv maxv]);
       title(Axes, join(["Distribution of " property " from Swift"],""));
       if property == "MSD"
           xlabel(Axes, sprintf("MSD in [%s²]", lengthUnit));
       else
           xlabel(Axes, sprintf("D in [%s²/s]", lengthUnit));
       end
 
       %% Decide if we fit or not
       if performFit
           %% perform fit
           pdGauss = fitdist(data, "Normal");
           pdKernel = fitdist(data, "Kernel", "Width", []);

           %% generate matching data
           xFitData = minv:1:maxv;
           yGauss = pdf(pdGauss, xFitData);
           yKernel = pdf(pdKernel, xFitData);

           %% plot
           hold(Axes,"on")
           plot(xFitData, yGauss, "--r");
           plot(xFitData, yKernel, "k");
           legend("GaussFit", "KernelFit");
           hold(Axes,"off")
           
           %% get the data from fit
           gaussDat = [median(pdGauss), mean(pdGauss), std(pdGauss), var(pdGauss)];
           kernelDat = [median(pdKernel), mean(pdKernel), std(pdKernel), var(pdKernel)];
       else
           gaussDat = [];
           kernelDat = [];
       end
end