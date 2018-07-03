# syntax
[![GitHub release](https://img.shields.io/github/release/omarroth/syntax.cr.svg)](https://github.com/omarroth/syntax.cr/releases)

> This is a project built with [marpa](https://github.com/omarroth/marpa).

Flexible syntax highlighter.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  syntax:
    github: omarroth/syntax.cr
```

## Usage

```crystal
require "syntax"

highlighter = Syntax::Highlighter.new
grammar = <<-'END_BNF'
# Grammar from https://metacpan.org/pod/distribution/Marpa-R2/pod/Semantics.pod
:start ::= Expression
Expression ::= Number
| '(' Expression ')' bgcolor => salmon
|| Expression '**' Expression bgcolor => red
|| Expression '*' Expression bgcolor => yellow color => black
| Expression '/' Expression bgcolor => green color => orange
|| Expression '+' Expression bgcolor => blue color => orange
| Expression '-' Expression bgcolor => cyan color => black

Number ~ [\d]+

:discard ~ whitespace
whitespace ~ [\s]+
END_BNF

input = "10 + (6 - 1 / 3) * 2"

highlighter.highlight(input, grammar)
```

## Contributing

1. Fork it (<https://github.com/omarroth/syntax.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [omarroth](https://github.com/omarroth) Omar Roth - creator, maintainer
