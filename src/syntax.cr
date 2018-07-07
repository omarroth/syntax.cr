require "./syntax/*"
require "marpa"

module Syntax
  class Highlighter
    # Given `input` and `input_grammar`, parse input and then style with colors
    # specified in `input_grammar`. If the input does not fully conform to the given grammar,
    # `forgiving` can be specified to attempt to correct the given input.
    def highlight(input : String, input_grammar : String, forgiving : Bool = false)
      parser = Marpa::Parser.new

      spec = Marpa::Builder.new
      spec = build_spec(spec)

      grammar = Grammar.new
      parser.parse(input_grammar, spec, actions: grammar)
      rules = grammar.rules

      actions = Actions.new(rules)
      events = Events.new(forgiving)
      stack = parser.parse(input, grammar, actions: actions, events: events)
      stack = stack.as(Array).flatten

      parser.values.to_a.reverse.each_with_index do |values, i|
        key, value = values
        key = key.abs

        input = input.sub(key..(key + value.size - 1), stack[stack.size - i - 1])
      end

      return input
    end
  end

  class Events < Marpa::Events
    property forgiving

    def initialize(forgiving = true)
      @forgiving = forgiving
    end

    def default(context)
      if @forgiving
        if context.matches.empty? && context.discards.empty?
          context.expected.each do |expected|
            context.matches << {"", expected}
          end
        end
      end
    end
  end

  class Actions < Marpa::Actions
    property rules

    def initialize(rules : Hash(Int32, Hash(String, String)))
      @rules = rules
    end

    def perform_color(context, rule_id)
      rule = @rules[rule_id]

      bgcolor = rule["bgcolor"]?
      bgcolor ||= "inherit"

      color = rule["color"]?
      color ||= "inherit"

      span = %(<span style="background-color:#{bgcolor}; color:#{color}">)
      end_span = "</span>"

      body = context.as(Array)
      body = body.flatten

      context.clear

      body[0] = span + body[0]
      body[-1] = body[-1] + end_span
      body.each do |element|
        context << element
      end

      context
    end
  end

  class Grammar < Marpa::Builder
    def adverb_list(context)
      adverbs = context.dup
      adverbs = adverbs.as(Array)
      context.clear

      adverbs.each do |adverb|
        adverb = adverb[0].as(Array)

        case adverb[0]
        when "color", "bgcolor"
          context << adverb
          context << ["action", "=>", "perform_color"]
        when "action"
        else
          context << adverb
        end
      end

      context
    end

    def css_color(context)
      colors = {
        "aliceblue"            => "#F0F8FF",
        "antiquewhite"         => "#FAEBD7",
        "aqua"                 => "#00FFFF",
        "aquamarine"           => "#7FFFD4",
        "azure"                => "#F0FFFF",
        "beige"                => "#F5F5DC",
        "bisque"               => "#FFE4C4",
        "black"                => "#000000",
        "blanchedalmond"       => "#FFEBCD",
        "blue"                 => "#0000FF",
        "blueviolet"           => "#8A2BE2",
        "brown"                => "#A52A2A",
        "burlywood"            => "#DEB887",
        "cadetblue"            => "#5F9EA0",
        "chartreuse"           => "#7FFF00",
        "chocolate"            => "#D2691E",
        "coral"                => "#FF7F50",
        "cornflowerblue"       => "#6495ED",
        "cornsilk"             => "#FFF8DC",
        "crimson"              => "#DC143C",
        "cyan"                 => "#00FFFF",
        "darkblue"             => "#00008B",
        "darkcyan"             => "#008B8B",
        "darkgoldenrod"        => "#B8860B",
        "darkgray"             => "#A9A9A9",
        "darkgreen"            => "#006400",
        "darkgrey"             => "#A9A9A9",
        "darkkhaki"            => "#BDB76B",
        "darkmagenta"          => "#8B008B",
        "darkolivegreen"       => "#556B2F",
        "darkorange"           => "#FF8C00",
        "darkorchid"           => "#9932CC",
        "darkred"              => "#8B0000",
        "darksalmon"           => "#E9967A",
        "darkseagreen"         => "#8FBC8F",
        "darkslateblue"        => "#483D8B",
        "darkslategray"        => "#2F4F4F",
        "darkslategrey"        => "#2F4F4F",
        "darkturquoise"        => "#00CED1",
        "darkviolet"           => "#9400D3",
        "deeppink"             => "#FF1493",
        "deepskyblue"          => "#00BFFF",
        "dimgray"              => "#696969",
        "dimgrey"              => "#696969",
        "dodgerblue"           => "#1E90FF",
        "firebrick"            => "#B22222",
        "floralwhite"          => "#FFFAF0",
        "forestgreen"          => "#228B22",
        "fuchsia"              => "#FF00FF",
        "gainsboro"            => "#DCDCDC",
        "ghostwhite"           => "#F8F8FF",
        "gold"                 => "#FFD700",
        "goldenrod"            => "#DAA520",
        "gray"                 => "#808080",
        "green"                => "#008000",
        "greenyellow"          => "#ADFF2F",
        "grey"                 => "#808080",
        "honeydew"             => "#F0FFF0",
        "hotpink"              => "#FF69B4",
        "indianred"            => "#CD5C5C",
        "indigo"               => "#4B0082",
        "ivory"                => "#FFFFF0",
        "khaki"                => "#F0E68C",
        "lavender"             => "#E6E6FA",
        "lavenderblush"        => "#FFF0F5",
        "lawngreen"            => "#7CFC00",
        "lemonchiffon"         => "#FFFACD",
        "lightblue"            => "#ADD8E6",
        "lightcoral"           => "#F08080",
        "lightcyan"            => "#E0FFFF",
        "lightgoldenrodyellow" => "#FAFAD2",
        "lightgray"            => "#D3D3D3",
        "lightgreen"           => "#90EE90",
        "lightgrey"            => "#D3D3D3",
        "lightpink"            => "#FFB6C1",
        "lightsalmon"          => "#FFA07A",
        "lightseagreen"        => "#20B2AA",
        "lightskyblue"         => "#87CEFA",
        "lightslategray"       => "#778899",
        "lightslategrey"       => "#778899",
        "lightsteelblue"       => "#B0C4DE",
        "lightyellow"          => "#FFFFE0",
        "lime"                 => "#00FF00",
        "limegreen"            => "#32CD32",
        "linen"                => "#FAF0E6",
        "magenta"              => "#FF00FF",
        "maroon"               => "#800000",
        "mediumaquamarine"     => "#66CDAA",
        "mediumblue"           => "#0000CD",
        "mediumorchid"         => "#BA55D3",
        "mediumpurple"         => "#9370DB",
        "mediumseagreen"       => "#3CB371",
        "mediumslateblue"      => "#7B68EE",
        "mediumspringgreen"    => "#00FA9A",
        "mediumturquoise"      => "#48D1CC",
        "mediumvioletred"      => "#C71585",
        "midnightblue"         => "#191970",
        "mintcream"            => "#F5FFFA",
        "mistyrose"            => "#FFE4E1",
        "moccasin"             => "#FFE4B5",
        "navajowhite"          => "#FFDEAD",
        "navy"                 => "#000080",
        "oldlace"              => "#FDF5E6",
        "olive"                => "#808000",
        "olivedrab"            => "#6B8E23",
        "orange"               => "#FFA500",
        "orangered"            => "#FF4500",
        "orchid"               => "#DA70D6",
        "palegoldenrod"        => "#EEE8AA",
        "palegreen"            => "#98FB98",
        "paleturquoise"        => "#AFEEEE",
        "palevioletred"        => "#DB7093",
        "papayawhip"           => "#FFEFD5",
        "peachpuff"            => "#FFDAB9",
        "peru"                 => "#CD853F",
        "pink"                 => "#FFC0CB",
        "plum"                 => "#DDA0DD",
        "powderblue"           => "#B0E0E6",
        "purple"               => "#800080",
        "rebeccapurple"        => "#663399",
        "red"                  => "#FF0000",
        "rosybrown"            => "#BC8F8F",
        "royalblue"            => "#4169E1",
        "saddlebrown"          => "#8B4513",
        "salmon"               => "#FA8072",
        "sandybrown"           => "#F4A460",
        "seagreen"             => "#2E8B57",
        "seashell"             => "#FFF5EE",
        "sienna"               => "#A0522D",
        "silver"               => "#C0C0C0",
        "skyblue"              => "#87CEEB",
        "slateblue"            => "#6A5ACD",
        "slategray"            => "#708090",
        "slategrey"            => "#708090",
        "snow"                 => "#FFFAFA",
        "springgreen"          => "#00FF7F",
        "steelblue"            => "#4682B4",
        "tan"                  => "#D2B48C",
        "teal"                 => "#008080",
        "thistle"              => "#D8BFD8",
        "tomato"               => "#FF6347",
        "turquoise"            => "#40E0D0",
        "violet"               => "#EE82EE",
        "wheat"                => "#F5DEB3",
        "white"                => "#FFFFFF",
        "whitesmoke"           => "#F5F5F5",
        "yellow"               => "#FFFF00",
        "yellowgreen"          => "#9ACD32",
      }

      context[0] = colors[context[0].as(String).downcase]
    end
  end
end

grammar = <<-'END_BNF'
# Adapted from https://gist.github.com/pstuifzand/4447349
:start ::= json
json ::= object | array

object ::= '{' members '}'
members ::= pair* proper => 1 separator => comma
pair ::= string ':' value

value ::= string
  | object
  | number
  | array
  | true
  | false
  | null

array ::= '[' elements ']' bgcolor => green
elements ::= value* proper => 1 separator => comma

comma ~ ','

string ::= '"' in_string '"' color => tan
in_string ~ /([^"\\]|\\[\"\\\/bftnrt]|\\u[a-fA-F0-9]{4})*/
number ~ /-?([\d]+)(\.\d+)?([eE][+-]?\d+)?/

true ~ 'true'
false ~ 'false'
null ~ 'null'

:discard ~ whitespace
whitespace ~ [\s]+
END_BNF
input = <<-'END_INPUT'
[1,"abc\nd\"ef\ufea1",true,
"",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}]
END_INPUT

highlighter = Syntax::Highlighter.new
output = highlighter.highlight(input, grammar)
puts output
File.write("output.html", "<pre>" + output + "</pre>")
# puts highlighter.stack
