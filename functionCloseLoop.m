function [MSEvector,MAPEvector,percVector] = functionCloseLoop(delay)
% Solve an Autoregression Problem with External Input with a NARX Neural Network
% Script generated by NTSTOOL
% Created Thu Jul 10 16:18:36 CEST 2014

load('tempWork.mat');
load('net.mat');

% Initialize vectors will containing average MSE, MAPE and percentage
% Each row contains the value for the corrisponding step
MSEvector = zeros(10, 1);
MAPEvector = zeros(10, 1);
percVector = zeros(10, 1);

disp('Forecasting Period:');

for steps = 1:10
    
    for i = 1:268-delay-steps+1
    
        inputSeries = tonndata(forecastingMatrix(i:i+delay+steps-1,:),false,false);
        targetSeries = tonndata(forecastingTargets(i:i+delay+steps-1,:),false,false);

        % Closed Loop Network
        % Use this network to do multi-step prediction.
        % The function CLOSELOOP replaces the feedback input with a direct
        % connection from the outout layer.
        netc = closeloop(net);
        netc.name = [net.name ' - Closed Loop'];
        [xc,xic,aic,tc] = preparets(netc,inputSeries,{},targetSeries);
        yc = netc(xc,xic,aic);
        performance = perform(netc,tc,yc);
        
        outputCL = cell2mat(yc);
        targetCL = cell2mat(tc);
        lenOut = size(outputCL,2);
        lenTar = size(targetCL,2);
    
        % Save performance to computing average MSE
        MSEvector(steps, 1) = MSEvector(steps, 1) + performance;
        % Save MAPE (take only the last values of targets and outputs)
        MAPEvector(steps, 1) =  MAPEvector(steps, 1) + abs((targetCL(1,lenTar) - outputCL(1,lenOut)) / targetCL(1,lenTar)) * 100;
        
        if (sign(targetCL(1,lenTar)) == sign(outputCL(1,lenOut)))
            percVector(steps, 1) = percVector(steps, 1) + 1;
        end

    end

    % Computing average values
    MSEvector(steps, 1) = MSEvector(steps, 1) / (268-delay-steps+1);
    MAPEvector(steps, 1) = MAPEvector(steps, 1) / (268-delay-steps+1);
    percVector(steps, 1) = (percVector(steps, 1) / (268-delay-steps+1)) * 100;
    
    string = '#steps: %d\tMSE: %f\tMAPE: %f\tPercentage: %f%%\n';
    fprintf(string, steps, MSEvector(steps,1), MAPEvector(steps,1), percVector(steps,1));
    
end
    save('MSEvector.mat','MSEvector');
    save('MAPEvector.mat','MAPEvector');
    save('percVector.mat','percVector');

end