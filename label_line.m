function hlabel = label_line(h, pos, opts)
% label_line put text label near line
%
% Prior to calling this function, the plot should be scaled to it's final
% size.  The offsets and slope are done in screen coordinates.
% Each label drawn will force a call to drawnow, may be slow for a large
% number of labels, but this is not the anticipated use case.
%
% INPUTS:
%  h        - handle to graphics object
%  pos      - relative position along line, defaults to 0.5
%             if given as array, multiple labels are placed
% OPTIONS (name/value pairs)
%  String    - label string, defaults to h.DisplayName
%  xoffset   - force additional offset in the X direction, points
%  yoffset   - force additional offset in the Y direction, points
%  Sloped    - logical, default to false which displays text at 0 angle
%              when sloped is true, x and y offsets are relative to the
%              line angle
%  Location  - string with location of label relative to plot.  Should be
%              one of "above", "below", "left", "right", "above left", 
%              "above right", "below left", "below right", "center".
%              Defaults to "above"
%  Color     - label string color, defaults to h.Color
%  BackgroundColor - label background color, defaults to none
%
% OPTIONS (used for development, not recommended)
%  baseOffset- Baseline offset in direction of location
%
% TODO: Implement text arrow option
% TODO: Verify functionality in tiled layout
% TODO: Consider x-position option to set label at specific x coord
% TODO: Handle nan's between line segments

arguments
    h (1, 1) matlab.graphics.chart.primitive.Line
    pos (1, :) double {mustBeInRange(pos, 0, 1, "inclusive")} = 0.5
    opts.String (1, 1) string = h.DisplayName
    opts.Sloped (1, 1) logical = false;
    opts.Location (1, 1) string {mustBeMember(opts.Location, ...
        ["above", "below", "left", "right", ...
        "above left", "above right", "below left", "below right", ...
        "center"])} = "above";
    opts.xoffset (1, 1) double = 0;
    opts.yoffset (1, 1) double = 0;
    opts.Color = h.Color;
    opts.baseOffset (1, 1) double = 2; 
    opts.BackgroundColor = "none";
end

% convert to screen coordinates
[xs, ys, ~, ~, hf] = data_to_screen(h);

% patch nan's
[xs1, ys1] = patch_nans(xs, ys);

% calculate point on line
[xp, yp, ap] = find_point(xs1, ys1, pos);

% place text box
hlabel = gobjects(size(xp));
for i = 1:numel(xp)
    hlabel(i) = make_text_box(xp(i), yp(i), ap(i), hf, opts);
end

end

function [xs, ys, scaleX, scaleY, hf] = data_to_screen(h)
% convert data coordiantes to screen coordinates in points
ha = h.Parent;
x = h.XData - ha.XLim(1);
y = h.YData - ha.YLim(1);

% walk up parent chain until we find a figure
hf = ha;
foundFigure = false;
while ~isempty(hf)
    hf = hf.Parent;
    if isa(hf, 'matlab.ui.Figure')
        foundFigure = true;
        break;
    end
end
assert(foundFigure, "No figure found in axes parent tree");

POINTS_PER_INCH = 72;
DPI = get(groot, "ScreenPixelsPerInch");

dataWidth = ha.XLim(2) - ha.XLim(1);
dataHeight = ha.YLim(2) - ha.YLim(1);
pos = getpixelposition(ha)./DPI.*POINTS_PER_INCH;
screenWidth = pos(3);
screenHeight = pos(4);

% inferred aspect raito from pixelposition doesn't match what's actually on
% screen.  Actual display aligns with PlotBoxAspectRatio.  This correction
% seems to work
scaleX = screenWidth./dataWidth;
scaleY = screenHeight./dataHeight ...
  .* ha.PlotBoxAspectRatio(2)./ha.PlotBoxAspectRatio(1) ...
  .* screenWidth./screenHeight;
xs = x.*scaleX+pos(1);
ys = y.*scaleY+pos(2);

end

function [x1, y1] = patch_nans(x, y)
% removes any nans in preparation for parameterization

% remove leading and trailing nans
idx1 = find(~isnan(x) & ~isnan(y), 1, "first");
idx2 = find(~isnan(x) & ~isnan(y), 1, "last");
x1 = x(idx1:idx2);
y1 = y(idx1:idx2);

% can't handle internal nan's here, would need to handle in integral.
% maybe we skip internal nans for now

end

function [xp, yp, ap] = find_point(xs, ys, pos)
% parameterize curve as a function of arc length
% find point on parametric line

% handle degenerate case
if isscalar(xs)
    xp = xs;
    yp = ys;
    ap = 0;
    return;
end

dx = diff(xs);
dy = diff(ys);
ds = sqrt(dx.^2+dy.^2);
theta = atan2d(dy, dx);
t = [0, cumsum(ds)];
t1 = t./t(end);

fx = griddedInterpolant(t1, xs);
fy = griddedInterpolant(t1, ys);

% make angle interpolant, for widely spaced points, the angle needs to
% change in discrete jumps
ta = [t1(1), ...
  reshape([t1(2:end-1);t1(2:end-1)+eps(t1(2:end-1))], 1, []), ...
  t1(end)];
theta2 = reshape([theta; theta], 1, []);
fa = griddedInterpolant(ta, theta2);

xp = fx(pos);
yp = fy(pos);
ap = fa(pos);
end

function hlabel = make_text_box(xp, yp, theta, hf, opts)
unitsOld = hf.Units;
hf.Units = "points";

vert = "bottom";
horz = "center";
xoffset = 0;
yoffset = opts.baseOffset;
if contains(opts.Location, "below")
    vert = "top";
    yoffset = -opts.baseOffset;
elseif contains(opts.Location, "center")
    vert = "middle";
    yoffset = 0;
end

if contains(opts.Location, "left")
    horz="right";
    xoffset = -opts.baseOffset;
elseif contains(opts.Location, "right")
    horz="left";
    xoffset = opts.baseOffset;
end

xoffset1 = xoffset + opts.xoffset;
yoffset1 = yoffset + opts.yoffset;

if opts.Sloped
    % shift offsets relative to angle
    alpha = atan2d(yoffset1, xoffset1);
    L = sqrt(xoffset1.^2+yoffset1.^2);
    xoffset2 = -L*cosd(theta-alpha);
    yoffset2 = -L*sind(theta-alpha);
else
    xoffset2 = xoffset1;
    yoffset2 = yoffset1;
end

% place text box, will need to shift later
hlabel = annotation(hf, "textbox", ...
    String=opts.String, ...
    Color=opts.Color, ...
    BackgroundColor=opts.BackgroundColor, ...
    LineStyle="none", ...
    Margin=0, ...
    Units="points", ...
    VerticalAlignment=vert, ...
    HorizontalAlignment=horz, ...
    Interpreter="tex", ...
    Position=[xp+xoffset2,yp+yoffset2,1, 1], ...
    FitBoxToText=true);

if opts.Sloped
    % save default position, with size containing text
    drawnow;
    pos = hlabel.Position;
    % copyobj(hlabel, hlabel.Parent);

    % rotate label
    hlabel.Rotation = theta;

    % offset to correct for rotation about the lower left corner
    % really want to rotate about the anchor point
    % no correction needed for "above right"
    if opts.Location == "above"
        hlabel.Position(2) = pos(2) - 0.5*pos(3)*sind(theta);
        hlabel.Position(1) = pos(1) + 0.5*pos(3)*(1-cosd(theta));
    elseif opts.Location == "below"
        L = sqrt(pos(4).^2 + 0.25*pos(3).^2);
        alpha = atand(pos(4)/(0.5*pos(3)));
        hlabel.Position(1) = pos(1) - L*cosd(theta+alpha) + 0.5*pos(3);
        hlabel.Position(2) = pos(2) - L*sind(theta+alpha) + pos(4);
    elseif opts.Location == "below right"
        hlabel.Position(1) = pos(1) + pos(4)*sind(theta);
        hlabel.Position(2) = pos(2) + pos(4)*(1-cosd(theta));
    elseif opts.Location == "above left"
        hlabel.Position(1) = pos(1) + pos(3)*(1-cosd(theta));
        hlabel.Position(2) = pos(2) - pos(3)*sind(theta);
    elseif opts.Location == "below left"
        L = sqrt(pos(4).^2+pos(3).^2);
        alpha = atand(pos(4)/pos(3));
        hlabel.Position(1) = pos(1) + pos(3) - L*cosd(theta+alpha);
        hlabel.Position(2) = pos(2) + pos(4) - L*sind(theta+alpha);
    end
end



hf.Units = unitsOld;
end