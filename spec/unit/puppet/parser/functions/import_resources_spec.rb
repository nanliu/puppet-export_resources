#!/usr/bin/env rspec
require 'spec_helper'

describe "the import_resources function" do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  before :each do
    @scope = Puppet::Parser::Scope.new
  end

  it "should exist" do
    Puppet::Parser::Functions.function("import_resources").should == "function_import_resources"
  end

  it "should raise a ParseError if recieved less than 2 arguments" do
    lambda { @scope.function_import_resources(['/foo']) }.should( raise_error(Puppet::ParseError, 'import_resources(): wrong number of arguments 1, expecting (path, title).'))
  end

  it "should raise a ParseError if path is relative." do
    lambda { @scope.function_import_resources(['foo', 'bar']) }.should( raise_error(Puppet::ParseError, 'import_resources(): path foo is not absolute.'))
  end

  it "should raise a Error if path is not a directory." do
    File.stubs(:exists?).with('/foo').returns true
    File.stubs(:directory?).with('/foo').returns false
    lambda { @scope.function_import_resources(['/foo', 'bar']) }.should( raise_error(Puppet::Error, 'import_resources(): path /foo is not a directory.'))
  end

end
