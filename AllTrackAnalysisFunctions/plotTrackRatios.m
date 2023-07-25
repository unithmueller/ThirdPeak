function [minv, maxv, gaussDat, kernelDat] = plotTrackRatios(Axes, binNumbers, SaveStructure, property, dimension, isPixel, lengthUnit, filterIDs, performFit)
%Function to plot the respective absolute and netto distances as well as the ratio as a histogram in the track
%analysis window.
%Input: Axes - axes object to plot into
       %SaveStructure - structured array that contains the data
       %property - decides between abs length, net length or ratio
       %dimension - defines the dimensionality to be plotted (XY,XYZ)
       %filterIDs - if we use a filter we can provide the ids to search for
       %here
       %performFit - will try to perform several fits to find a matching
       %distribution
       
       %% Get the data of choice
       data = SaveStructure.TrackLength.(property).(dimension);
       
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
       %% decide on the labelling of the plot
       if property == "NetLength"
           title(Axes, join(["Netto Length Distribution of Tracks for " dimension],""));
           if isPixel
               xlabel(Axes, "Netto Track Distance in [px]");
           else
               xlabel(Axes, sprintf("Netto Track Distance in [%s]", lengthUnit));
           end
       elseif property == "AbsLength"
               title(Axes, join(["Total Track Distance Distribution of Tracks for " dimension],""));
           if isPixel
               xlabel(Axes, "Total Track Distance in [px]");
           else
               xlabel(Axes, sprintf("Total Track Distance in [%s]", lengthUnit));
           end
       elseif property == "ConfRatio"
               title(Axes, join(["Confinement Ratio Distribution of Tracks for " dimension],""));
               xlabel(Axes, "Ratio Total Distance/Netto Distance");
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