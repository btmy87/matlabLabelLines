function label_line(h, pos, opts)
% label_line put text label near line
%
% INPUTS:
%  h        - handle to graphics object
%  pos      - relative position along line, defaults to 0.5
% OPTIONS (name/value pairs)
%  string   - label string, defaults to h.DisplayName
%  offset   - 1x2 array with [x-offset, y-offset] in points for the anchor
%            point of the text box
%  sloped   - bool, default to false which displays text at 0 angle
%  location - string with location of label relative to plot.  Should be
%             one of "above", "below", "left", "right", "above left", 
%             "above right", "below left", "below right", "center".
%             Defaults to "above"

arguments
    h (1, 1) matlab.graphics.chart.primitive.Line
    pos (1, 1) double {mustBeInRange(pos, 0, 1, "inclusive")} = 0.5
    opts.string (1, 1) string = h.DisplayName
    opts.offset (1, 2) double = [0, 2]
    opts.location (1, 1) string {mustBeMember(opts.location, ...
        ["above", "below", "left", "right", ...
        "above left", "above right", "below left", "below right", ...
        "center"])} = "above";
end





end