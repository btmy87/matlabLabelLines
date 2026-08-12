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
ha.YLim = [-1, 2];
h = plot(0, 0, ".", DisplayName="below left");
label_line(h, location=h.DisplayName);

h = plot(1, 0, ".", DisplayName="below");
label_line(h, location=h.DisplayName);

h = plot(2, 0, ".", DisplayName="below right");
label_line(h, location=h.DisplayName);

h = plot(0, 1, ".", DisplayName="above left");
label_line(h, location=h.DisplayName);

h = plot(1, 1, ".", DisplayName="above");
label_line(h, location=h.DisplayName);

h = plot(2, 1, ".", DisplayName="above right");
label_line(h, location=h.DisplayName);

ha.XTick = [];
ha.YTick = [];

%% ex0.2 Check slope calcs for all positions
% plot labels around unit circle
theta = linspace(0, 2*pi, 361);
x = cos(theta);
y = sin(theta);

locs = ["above left", "above", "above right", ...
        "below left", "below", "below right"];

hf = figure(Name="ex0.2 Slope with Options", ...
    Units="inches", Position=[1,1,12,8]);
tiledlayout(2, 3, TileSpacing="compact", Padding="compact");
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

figure(Name="ex0.5 singular nans", Units="inches", Position=[1,1,6,4]);
ha = axes;hold on;grid on;box on;
h = plot(x, y, "-", DisplayName="test");
ha.XLim = [-0.1, 1.1];
ha.YLim = [-0.1, 1.1];

label_line(h, 0.8, Sloped=true, String="Sloped");
label_line(h, 0.5, Sloped=true, Rotation=10, String="Sloped + Rot.=10");
label_line(h, 0.2, Sloped=false, Rotation=10, String="No Slope + Rot.=10");


