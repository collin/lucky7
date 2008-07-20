require 'rspec/jabs_spec_helper'
$LOAD_PATH << "~/code/johnson/js" unless $LOAD_PATH.include?("~/code/johnson/js")

describe Jabs::Engine do
  before(:each) do
    en = Jabs::Engine.new <<JABS
class Specd
:layout
  #magic
    %rendering
      .machine
    %renders
      %so/
      %well/
  %cool/

?well well
?cool coolio

!click well
  var me = "pleased";

!click well, cool
  var me = "very pleased";

JABS
    @js = en.render
    @r = Johnson::Runtime.new
    @r.evaluate('Johnson.require("johnson/browser");')
# Just lets not try to do anything with that document.
    @r.evaluate("window.document = {};")
    @r.evaluate('Johnson.require("vendor/jquery/jquery-1.2.6.js");')
    @r.evaluate('Johnson.require("lib/lucky7.js");')
    @r.evaluate('Johnson.require("lib/lucky7/template.js");')
    @r.evaluate @js
    @klass = @r[:Specd]
    @lucky7 = @r[:Lucky7]
  end

  it "klass is an object" do
    @klass.is_a?(Object).should == true
  end

  it "templates go Lucky7.Templates" do
    @r.evaluate("Lucky7.Template('Specd/layout.html') instanceof Lucky7.TemplateObject").should == true
  end

  it "renders templates with Haml" do
    @klass['templates']['layout'].should == <<HTML
<div id='magic'>
  <rendering>
    <div class='machine'></div>
  </rendering>
  <renders>
    <so />
    <well />
  </renders>
</div>
<cool />
HTML
  end

  it "generates code for actions" do
    binding = <<JS

jQuery(document).bind('ready', function() {
  jQuery(".Specd").bind({"click": function(event) {
    var el = jQuery(event.target);
    if(el.is("well")) {
      var me = "pleased";
  }
    if(el.is("well, coolio")) {
      var me = "very pleased";
  }
  } });
});
JS
    @js.gsub(' ', '').should include(binding.chomp.gsub(' ', ''))
  end
end
