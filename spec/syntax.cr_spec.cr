require "./spec_helper"

describe Syntax do
  # TODO: Write tests

  it "highlights text" do
    highlighter = Syntax::Highlighter.new

    grammar = <<-'END_BNF'
    :start ::= S
    S ::= 'a' color => green
    END_BNF

    highlighter.highlight("a", grammar).should eq %(<span style="background-color:inherit; color:#008000">a</span>)
  end
end
