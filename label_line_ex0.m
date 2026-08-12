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
label_line(h, 0.1:0.2:0.9, location="below", sloped=true);
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
theta = linspace(0, 2*pi, 101);
x = cos(theta);
y = sin(theta);

locs = ["above left", "above", "above right", ...
        "below left", "below", "below right"];

figure(Name="ex0.2 Slope with Options", Units="inches", Position=[1,1,12,8])
tiledlayout(2, 3);
for thisloc = locs
    ha = nexttile;hold on;box on;grid off
    ha.XLim = [-1, 1]*1.2;
    ha.YLim = [-1, 1]*1.2;
    title(thisloc, FontWeight="normal");
    h = plot(x, y, "-", DisplayName="test");
    label_line(h, 0:0.1:0.9, sloped=true, location=thisloc);
end

