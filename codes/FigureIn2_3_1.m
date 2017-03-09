%{

%% QE_European call option
% %InitializeWorkspaceDisplay %initialize the workspace and the display parameters
T=5;
delta_t=0.2;
t0 = delta_t;
inp.timeDim.timeVector = t0:delta_t:T; 
% To generate an asset path modeled by a geometric Brownian motion we need
% to add some more properties
initPrice = 80;
interest = 0.0;
inp.assetParam.initPrice = initPrice; %initial stock price
inp.assetParam.interest = interest; %risk-free interest rate
inp.assetParam.volatility = 0.3;
inp.assetParam.Vinst = 0.36; %0.04; 
inp.assetParam.Vlong = 0.09;
inp.assetParam.kappa = 1;
%inp.assetParam.nu = 0.5;
inp.assetParam.rho = -0.3;
inp.assetParam.pathType = 'QE_m';
inp.payoffParam.putCallType = {'call'};
%inp.priceParam.cubMethod = 'Sobol';
inp.priceParam.cubMethod = 'IID_MC';

%%
% To generate some discounted option payoffs to add some more properties
Strike = 100;
inp.payoffParam.strike =Strike; 

%% 
inp.priceParam.absTol = 0; %absolute tolerance
inp.priceParam.relTol = 0.01; %one penny on the dollar relative tolerance

Ntime = T/0.25; 
NSim = 1e6;
nu = [0,10^(-6),10^(-5),10^(-4),10^(-3),10^(-2),0.05,10^(-1),0.15,0.2];
ourQEprice = zeros(size(nu));
QEprice = zeros(size(nu));
for i = 1:length(nu)
    inp.assetParam.nu =nu(i);
    ourGBMCallPrice = optPrice(inp);
    [ourQEprice(i), out] = genOptPrice(ourGBMCallPrice);
    [pathS,pathV] = MC_QE(initPrice,interest,0,T,inp.assetParam.Vinst,inp.assetParam.Vlong,...
    inp.assetParam.kappa,inp.assetParam.nu,inp.assetParam.rho,Ntime,NSim,1);
    PT = pathS(:,Ntime + 1);
    PT = max(PT-Strike,0);
    PP = mean(PT);
    QEprice(i) = PP*exp(-inp.assetParam.interest*T);
end
v0 = ourQEprice(1)*ones(size(nu));
QEzero = zeros(size(nu));
%}

%nu = log(nu);
%nu = exp(nu);
n=10;
figure
plot(nu(1:n),ourQEprice(1:n),'-o',nu(1:n),QEprice(1:n),'-*','LineWidth',1.25)
title('QE scheme for small nu')
xlabel('log(nu)')
%xlabel('nu')
ylabel('Option price')
hold on
plot(nu(1:n),v0,'-.','LineWidth',1.25)
hold on
plot(nu(1:n),QEzero,'--g','LineWidth',2)
hold off