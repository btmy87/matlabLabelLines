%% label_line_ex0.m
% demonstrate usage of label_line

close all
clear
clc

%% ex0.0
figure(Name="ex0.0 Basic Usage", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;box on;grid off
xlabel("x");
ylabel("y");
x = linspace(-1, 1, 201);
y = x.^2;
h = plot(x, y, DisplayName="f(x)=x^2");
% h = plot(x, y, DisplayName="my line");
ha.XLim = [-1.1, 1.1];
ha.YLim = [-0.1, 1.1];

% additional offset needed on concave side
label_line(h, Color=ha.XColor, yoffset=2);

% multiple labels can be drawn with multiple position entries
label_line(h, 0.1:0.2:0.9, location="below", Sloped=true);
% label_line(h, 0.7, location="below right", sloped=true);

%% ex0.1 Demonstrate Position Options
figure(Name="ex0.1 Location Options", Units="inches", Position=[1,1,6,4])
ha = axes("defaultLineMarkerSize",12);hold on;box on;grid off
ha.XLim = [-1, 3];
ha.YLim = [-1, 3];
ha.XTick = [];
ha.YTick = [];

h = plot(0, 0, ".", DisplayName="below left");
label_line(h, location=h.DisplayName);

h = plot(1, 0, ".", DisplayName="below");
label_line(h, location=h.DisplayName);

h = plot(2, 0, ".", DisplayName="below right");
label_line(h, location=h.DisplayName);

h = plot(0, 1, ".", DisplayName="left");
label_line(h, location=h.DisplayName);

h = plot(1, 1, ".", DisplayName="center");
label_line(h, location=h.DisplayName);

h = plot(2, 1, ".", DisplayName="right");
label_line(h, location=h.DisplayName);

h = plot(0, 2, ".", DisplayName="above left");
label_line(h, location=h.DisplayName);

h = plot(1, 2, ".", DisplayName="above");
label_line(h, location=h.DisplayName);

h = plot(2, 2, ".", DisplayName="above right");
label_line(h, location=h.DisplayName);

exportgraphics(gcf, "ex01.png");


%% ex0.2 Check slope calcs for all positions
% plot labels around unit circle
theta = linspace(0, 2*pi, 361);
x = cos(theta);
y = sin(theta);

locs = ["above left", "above", "above right", ...
        "left", "center", "right", ...
        "below left", "below", "below right"];

hf = figure(Name="ex0.2 Slope with Options", ...
    Units="inches", Position=[1,1,10, 10]);
tiledlayout(3, 3, TileSpacing="compact", Padding="compact");
for thisloc = locs
    ha = nexttile;hold on;box on;grid off
    ha.XLim = [-1, 1]*1.2;
    ha.YLim = [-1, 1]*1.2;
    ha.XTick = [];
    ha.YTick = [];
    % ha.XAxis.Visible = "off";
    % ha.YAxis.Visible = "off";
    ha.Color = hf.Color;
    title(thisloc, FontWeight="normal");
    drawnow;
    h = plot(x, y, "-", DisplayName="test");
    label_line(h, 0:0.125:0.875, Sloped=true, location=thisloc);
end

%% ex0.3 Line segment with nans
x = linspace(0, 1, 101);
y = sqrt(x);
y(30) = nan;
x(60) = nan;
x(1:5) = nan;
y(95:end) = nan;

figure(Name="ex0.3 nan handling", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid on;box on;
h = plot(x, y, DisplayName="f(x)=sqrt(x)");
ha.XLim = [-0.1, 1.1];
ha.YLim = [-0.1, 1.1];

label_line(h, Sloped=true);

%% ex0.4 alternating nans
x = linspace(0, 1, 101);
y = sqrt(x);
y(1:2:end) = nan;

figure(Name="ex0.4 all alternating nans", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid on;box on;
h = plot(x, y, ".-", DisplayName="test");
ha.XLim = [-0.1, 1.1];
ha.YLim = [-0.1, 1.1];

label_line(h, Sloped=true);

%% ex0.5 singlular nans
x = linspace(0, 1, 101);
y = sqrt(x);
y([20, 22, 24]) = nan;

figure(Name="ex0.5 singular nans", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid on;box on;
h = plot(x, y, ".-", DisplayName="test");
ha.XLim = [-0.1, 1.1];
ha.YLim = [-0.1, 1.1];

label_line(h, Sloped=true);

%% ex0.6 Rotation
x = linspace(0, 1, 101);
y = sqrt(x);

figure(Name="ex0.5 srotation", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid on;box on;
h = plot(x, y, "-", DisplayName="test");
ha.XLim = [-0.1, 1.1];
ha.YLim = [-0.1, 1.1];

label_line(h, 0.8, Sloped=true, String="Sloped");
label_line(h, 0.5, Sloped=true, Rotation=10, String="Sloped + Rot.=10");
label_line(h, 0.2, Sloped=false, Rotation=10, String="No Slope + Rot.=10");

%% ex0.7
x = linspace(0, 2*pi, 101);

figure(Name="ex0.7 sin cos", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid off;box on;
ha.XLim = [0, 2*pi];
ha.YLim = [-1, 1]*1.1;
h = plot(x, sin(x), "-", DisplayName="sin(x)");
label_line(h, 0.5, Sloped=true);

h = plot(x, cos(x), "-", DisplayName="cos(x)");
label_line(h, 0.25, Pin=45);
exportgraphics(gcf, "ex07.png");


%% ex0.8 scatter
x = linspace(0, 2*pi, 51);

figure(Name="ex0.8 scatter", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid off;box on;
ha.XLim = [0, 2*pi];
ha.YLim = [-1, 1]*1.1;
h = scatter(x, sin(x), 30, sin(x), "filled", DisplayName="sin(x)");
label_line(h, 0.5, Sloped=true);

%% ex0.9 log
x = linspace(1, 10, 100);
figure(Name="ex0.9 log", Units="inches", Position=[1,1,6, 6])
tiledlayout(2, 2, TileSpacing="compact", Padding="compact");

nexttile;hold on;box on;grid on;
title("Linear", FontWeight="normal")
h = plot(x, x.^2, DisplayName="x^2");
label_line(h, [0.2, 0.5, 0.8], Sloped=true);

ha = nexttile;hold on;box on;grid on;
title("Semi-Log X", FontWeight="normal")
h = plot(x, x.^2, DisplayName="x^2");
ha.XScale = "log";
label_line(h, [0.2, 0.5, 0.8], Sloped=true);

ha = nexttile;hold on;box on;grid on;
title("Semi-Log Y", FontWeight="normal")
h = plot(x, x.^2, DisplayName="x^2");
ha.YScale = "log";
label_line(h, [0.2, 0.5, 0.8], Sloped=true);

ha = nexttile;hold on;box on;grid on;
title("Log-Log", FontWeight="normal")
h = plot(x, x.^2, DisplayName="x^2");
ha.XScale = "log";
ha.YScale = "log";
label_line(h, [0.2, 0.5, 0.8], Sloped=true);

exportgraphics(gcf, "ex09.png");

%% ex0.10 Trim
x = logspace(-2, 0, 1000);
figure(Name="ex0.10 trim", Units="inches", Position=[1,1,12, 4])
tiledlayout(1, 3);

ha = nexttile;hold on;grid off;box on;
title("Full Range", FontWeight="normal");
h = plot(x, log(x), DisplayName="log(x)");
ha.XLim(1) = -0.2;
label_line(h, Sloped=true);

ha = nexttile;hold on;grid off;box on;
title("Partial range with trim", FontWeight="normal");
h = plot(x, log(x), DisplayName="log(x)");
ha.XLim(1) = -0.2;
ha.YLim(1) = -2;
label_line(h, Sloped=true);

ha = nexttile;hold on;grid off;box on;
title("Partial range without trim", FontWeight="normal");
h = plot(x, log(x), DisplayName="log(x)");
ha.XLim(1) = -0.2;
ha.YLim(1) = -2;
label_line(h, Sloped=true, Trim=false);
% label drawn off-screen

%% ex0.11 Pin Locations
figure(Name="ex011 Pin Locations", Units="inches", Position=[1,1,4,2]);
ha = axes;hold on;grid off;box on;
ha.XLim = [-1, 1];
ha.YLim = [-1, 1];
ha.XTick = [];
ha.YTick = [];
title("Location Option with Pin Command", FontWeight="normal");

h = plot(0, 0, ".");

% label_line(h, String="left", Pin=0);
% label_line(h, String="above left", Pin=45);
% label_line(h, String="above", Pin=90);
% label_line(h, String="above right", Pin=135);
% label_line(h, String="right", Pin=180);
% label_line(h, String="below right", Pin=225);
% label_line(h, String="below", Pin=270);
% label_line(h, String="below left", Pin=315);

% label_line(h, String="left"       , Location="left"       , BaseOffset=18);
% label_line(h, String="above left" , Location="above left" , BaseOffset=18);
% label_line(h, String="above"      , Location="above"      , BaseOffset=18);
% label_line(h, String="above right", Location="above right", BaseOffset=18);
% label_line(h, String="right"      , Location="right"      , BaseOffset=18);
% label_line(h, String="below right", Location="below right", BaseOffset=18);
% label_line(h, String="below"      , Location="below"      , BaseOffset=18);
% label_line(h, String="below left" , Location="below left" , BaseOffset=18);

label_line(h, String="left"       , Location="left"       , Pin=180, PinOffset=2);
label_line(h, String="above left" , Location="above left" , Pin=135, PinOffset=2);
label_line(h, String="above"      , Location="above"      , Pin=90 , PinOffset=2);
label_line(h, String="above right", Location="above right", Pin=45 , PinOffset=2);
label_line(h, String="right"      , Location="right"      , Pin=0  , PinOffset=2);
label_line(h, String="below right", Location="below right", Pin=315, PinOffset=2);
label_line(h, String="below"      , Location="below"      , Pin=270, PinOffset=2);
label_line(h, String="below left" , Location="below left" , Pin=225, PinOffset=2);




