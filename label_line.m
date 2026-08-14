function [hlabel, hpin] = label_line(h, pos, opts)
% label_line put text label near line
%
% Prior to calling this function, the plot should be scaled to it's final
% size.  The offsets and slope are done in screen coordinates.
% Each label drawn will force a call to drawnow, may be slow for a large
% number of labels, but this is not the anticipated use case.
% 
% It's possible for the label to be rendered off-screen.  The default Trim
% option prevents this for most cases, but no check is performed to
% guarantee the label is visible.
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
%              Defaults to "above" if the pin option isn't used
%              When the Pin option is used, a suitable location is selected
%              based on the pin angle.
%  Color     - label string color, defaults to h.Color
%  BackgroundColor - label background color, defaults to none
%  Rotation  - Rotation angle in degrees, defaults to 0
%              when Sloped is true, this is an adjustment to the base
%              rotation angle
%  Trim      - trim lines to plot box before doing position calcs
%              defaults to true
%  Pin       - Set to [Pin Angle (deg), Pin Length (pts)] to add a leader
%              line to label.  When using the Pin option, the Location
%              option will indicate where the pin terminates at the label
%              Defaults to [], in which case no pin is drawn.
%              If only a single number is provided, it will be treated as
%              the pin angle, and the length will be 36 pts.
%
%  PIN Options (see Annotation, Arrow for more information)
%  PinLineStyle  - Pin line style, default '-'
%  PinLineWidth  - Pin line width, default 0.5
%  PinHeadStyle  - Pin head style, default "vback2"
%  PinHeadLength - Length of arrowhead, in points, default 6
%  PinHeadWidth  - Width of arrowhead, in points, default 6
%  PinOffset     - Offset from end of pin to line
%                  Note this is not a standard annotation option
%  
%
% OPTIONS (used for development, not recommended)
%  baseOffset- Baseline offset in direction of location
%  baseOffsetBelow - Additional offset in the below direction
%                    When above, an additional effective offset is visible
%                    because the text baseline is not at the bottom of the
%                    box
%  defaultPinLength - Default length for pin, 24
%
% Notes
%  - Does not work with xline or yline, but these contain their own
%    label options
%
% TODO: Consider x-position option to set label at specific x coord
%       Or maybe a specific index
% TODO: How do we address deprecation of mustBeInRange, but still work
%       in older versions

arguments
    h (1, 1) {mustBeA(h, [ ...
        "matlab.graphics.chart.primitive.Line", ...
        "matlab.graphics.chart.primitive.Scatter"])}
    pos (1, :) double {mustBeInRange(pos, 0, 1, "inclusive")} = 0.5
    opts.String (1, 1) string = h.DisplayName
    opts.Sloped (1, 1) logical = false;
    opts.Location (1, 1) string {mustBeMember(opts.Location, ...
        ["above", "below", "left", "right", ...
        "above left", "above right", "below left", "below right", ...
        "center", ""])} = "";
    opts.xoffset (1, 1) double = 0;
    opts.yoffset (1, 1) double = 0;
    opts.Color = [];
    opts.baseOffset (1, 1) double = 2; 
    opts.baseOffsetBelow (1, 1) double = 2;
    opts.BackgroundColor = "none";
    opts.Rotation (1, 1) double = 0;
    opts.Trim (1, 1) logical = true;
    opts.Pin (1, :) double = [];
    opts.defaultPinLength (1, 1) double = 24; % pts
    opts.PinLineStyle (1, 1) string = "-";
    opts.PinLineWidth (1, 1) double = 0.5;
    opts.PinHeadStyle (1, 1) string = "vback2";
    opts.PinHeadLength (1, 1) double = 6;
    opts.PinHeadWidth (1, 1) double = 4;
    opts.PinOffset (1, 1) double = 1;
end

% default color based on type
if isempty(opts.Color) && isa(h, "matlab.graphics.chart.primitive.Line")
    opts.Color = h.Color;
elseif isempty(opts.Color) && isa(h, "matlab.graphics.chart.primitive.Scatter")
    opts.Color = h.Parent.XColor;
end

% default location based on Pin option
if isempty(opts.Pin) && opts.Location == ""
    opts.Location = "above";
elseif ~isempty(opts.Pin) && opts.Location == ""
    % reasonable location based on pin angle
    ang = mod(opts.Pin, 360); % force to 0-360
    if ang < (0+22.5)
        opts.Location = "right";
    elseif ang < (45+22.5)
        opts.Location = "above right";
    elseif ang < (90+22.5)
        opts.Location = "above";
    elseif ang < (135+22.5)
        opts.Location = "above left";
    elseif ang < (180+22.5)
        opts.Location = "left";
    elseif ang < (225+22.5)
        opts.Location = "below left";
    elseif ang < (270+22.5)
        opts.Location = "below";
    elseif ang < (315+22.5)
        opts.Location = "below right";
    else
        opts.Location = "right";
    end
end

% convert to screen coordinates
[xs, ys, ~, ~, hf] = data_to_screen(h, opts.Trim);

% patch nan's
[xs1, ys1] = patch_nans(xs, ys);

% calculate point on line
[xp, yp, ap] = find_point(xs1, ys1, pos, opts.Rotation);

% place text box
hlabel = gobjects(size(xp));
hpin = gobjects(size(xp));
for i = 1:numel(xp)
    [hlabel(i), hpin(i)] = make_text_box(xp(i), yp(i), ap(i), hf, opts);
end

end

function [xs, ys, scaleX, scaleY, hf] = data_to_screen(h, trim)
% convert data coordinates to screen coordinates in points
ha = h.Parent;

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

pos = getpixelposition(ha)./DPI.*POINTS_PER_INCH;
screenWidth = pos(3);
screenHeight = pos(4);

% inferred aspect ratio from pixelposition doesn't match what's actually on
% screen.  Actual display aligns with PlotBoxAspectRatio.  This correction
% seems to work
if ha.XScale == "linear"
    x = h.XData - ha.XLim(1);
    dataWidth = ha.XLim(2) - ha.XLim(1);
else % log scale
    x = log10(h.XData) - log10(ha.XLim(1));
    dataWidth = log10(ha.XLim(2)) - log10(ha.XLim(1));
end
scaleX = screenWidth./dataWidth;
xs = x.*scaleX+pos(1);

if ha.YScale == "linear"
    y = h.YData - ha.YLim(1);
    dataHeight = ha.YLim(2) - ha.YLim(1);
else
    y = log10(h.YData) - log10(ha.YLim(1));
    dataHeight = log10(ha.YLim(2)) - log10(ha.YLim(1));
end
scaleY = screenHeight./dataHeight ...
    .* ha.PlotBoxAspectRatio(2)./ha.PlotBoxAspectRatio(1) ...
    .* screenWidth./screenHeight;
ys = y.*scaleY+pos(2);


% trim data to axis limits
if trim
    idx = h.XData < ha.XLim(1) ...
        | h.XData > ha.XLim(2) ...
        | h.YData < ha.YLim(1) ...
        | h.YData > ha.YLim(2);
    xs(idx) = nan;
    ys(idx) = nan;
end

end

function [x1, y1] = patch_nans(x, y)
% removes any nans in preparation for parameterization

% remove leading and trailing nans/infs
idx1 = find(isfinite(x) & isfinite(y), 1, "first");
idx2 = find(isfinite(x) & isfinite(y), 1, "last");
x1 = x(idx1:idx2);
y1 = y(idx1:idx2);

% can't handle internal nan's here, would need to handle in integral.
% maybe we skip internal nans for now

end

function [xp, yp, ap] = find_point(xs, ys, pos, thetaAdj)
% parameterize curve as a function of arc length
% find point on parametric line

% handle degenerate case
if isscalar(xs)
    xp = xs;
    yp = ys;
    ap = thetaAdj;
    return;
end

t = [];
theta = [];
x1 = [];
y1 = [];
% idx1 = 1; % next point to process
idx2 = 0; % last point processed
flag = ~isfinite(xs) | ~isfinite(ys);
while idx2 < length(xs)
    % skip any leading nans
    idx1 = find(~flag(idx2+1:end), 1)+idx2;

    % process until next nan
    idx2 = find(flag(idx1:end), 1) + idx1 - 2;
    if isempty(idx2)
        idx2 = length(xs);
    end

    % integrate t vector and calc theta vector
    dx = diff(xs(idx1:idx2));
    dy = diff(ys(idx1:idx2));
    ds = sqrt(dx.^2+dy.^2);
    theta1 = atan2d(dy, dx);
    if isempty(theta1)
        % theta1 = 0; % case where only a single point exists between nans
        continue;
    end
    if isempty(t)
        t = [0, cumsum(ds)];
        theta = theta1;
    else
        t = [t, t(end)+eps(t(end)), cumsum(ds)+t(end)]; %#ok<AGROW>
        theta = [theta, 0.5*(theta(end)+theta1(1)), theta1]; %#ok<AGROW>
    end
    x1 = [x1, xs(idx1:idx2)]; %#ok<AGROW>
    y1 = [y1, ys(idx1:idx2)]; %#ok<AGROW>
end
if isempty(t)
    warning("No segments of finite length, but I'll give it a go anyways");
    tempx = xs(~flag);
    tempy = ys(~flag);
    idx = round(pos*length(tempx));
    idx = min(idx, length(tempx));
    idx = max(1, idx);
    xp = tempx(idx);
    yp = tempy(idx);
    if idx < length(tempx)
        ap = atan2d(tempy(idx+1)-tempy(idx), tempx(idx+1)-tempx(idx)) ...
           + thetaAdj;
    else
        ap = thetaAdj;
    end
    return;
end
t1 = t./t(end);
% after normalizing, eps may have collapsed
for i = 2:length(t1)
    t1(i) = max(t1(i), t1(i-1)+eps(t(i-1)));
end

fx = griddedInterpolant(t1, x1);
fy = griddedInterpolant(t1, y1);

% make angle interpolant, for widely spaced points, the angle needs to
% change in discrete jumps
ta = [t1(1), ...
  reshape([t1(2:end-1);t1(2:end-1)+eps(t1(2:end-1))], 1, []), ...
  t1(end)];
for i = 2:length(ta)
    ta(i) = max(ta(i), ta(i-1)+eps(ta(i-1)));
end
theta2 = reshape([theta; theta], 1, []);
fa = griddedInterpolant(ta, theta2);

xp = fx(pos);
yp = fy(pos);
ap = fa(pos)+thetaAdj;
end




function [hlabel, hpin] = make_text_box(xp, yp, theta, hf, opts)
% make_text_box draw the text box and the pin
% rotate label, and fix offsets after rotation
unitsOld = hf.Units;
hf.Units = "points";


vert = "middle";
yoffset = -0.5*opts.baseOffsetBelow;
if contains(opts.Location, "below")
    vert = "top";
    yoffset = -opts.baseOffset-opts.baseOffsetBelow;
elseif contains(opts.Location, "above")
    vert = "bottom";
    yoffset = opts.baseOffset;
end

horz = "center";
xoffset = 0;
if contains(opts.Location, "left")
    horz="right";
    xoffset = -opts.baseOffset;
elseif contains(opts.Location, "right")
    horz="left";
    xoffset = +opts.baseOffset;
end

xpin = 0.0;
ypin = 0.0;
if ~isempty(opts.Pin)
    if length(opts.Pin) < 2
        opts.Pin = [opts.Pin, opts.defaultPinLength];
    end
    xpin = opts.Pin(2)*cosd(opts.Pin(1));
    ypin = opts.Pin(2)*sind(opts.Pin(1));
end

xoffset1 = xoffset + opts.xoffset + xpin;
yoffset1 = yoffset + opts.yoffset + ypin;

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

% save default position, with size containing text
drawnow;
pos = hlabel.Position;
% copyobj(hlabel, hlabel.Parent);

% offset to correct for rotation about the lower left corner
% really want to rotate about the anchor point
Lx = 0.5*pos(3);
Ly = 0.5*pos(4);
if contains(opts.Location, "left")
    Lx = pos(3);
elseif contains(opts.Location, "right")
    Lx = 0.0;
end
if contains(opts.Location, "above")
    Ly = 0.0;
elseif contains(opts.Location, "below")
    Ly = pos(4);
end
L = sqrt(Lx.^2+Ly.^2);
alpha = atan2d(Ly, Lx);

if opts.Sloped || opts.Rotation ~= 0
    % rotate label
    if ~opts.Sloped
        theta=opts.Rotation;
    end
    hlabel.Rotation = theta;

    hlabel.Position(1) = pos(1) + L*(cosd(alpha) - cosd(theta+alpha));
    hlabel.Position(2) = pos(2) + L*(sind(alpha) - sind(theta+alpha));
end

hpin = gobjects(1);
if ~isempty(opts.Pin)
    hpin = annotation(hf, "arrow", ...
        Units="points", ...
        X=[xp+xpin, xp+opts.PinOffset*cosd(opts.Pin(1))], ...
        Y=[yp+ypin, yp+opts.PinOffset*sind(opts.Pin(1))], ...
        LineWidth=opts.PinLineWidth, ...
        Color=opts.Color, ...
        LineStyle=opts.PinLineStyle, ...
        HeadStyle=opts.PinHeadStyle, ...
        HeadLength=opts.PinHeadLength, ...
        HeadWidth=opts.PinHeadWidth);
end

hf.Units = unitsOld;
end