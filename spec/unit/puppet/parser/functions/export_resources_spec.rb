#!/usr/bin/env rspec
require 'spec_helper'

describe "the export_resources function" do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  before :each do
    @scope = Puppet::Parser::Scope.new
  end

  it "should exist" do
    Puppet::Parser::Functions.function("export_resources").should == "function_export_resources"
  end

  it "should raise a ParseError if recieved less than 3 arguments" do
    lambda { @scope.function_export_resources(['/foo']) }.should( raise_error(Puppet::ParseError, 'export_resources(): wrong number of arguments 1, expecting (path, title, param).'))
  end

  it "should raise a ParseError if third argument is not a Hash." do
    lambda { @scope.function_export_resources(['/foo', 'bar', 'baz']) }.should( raise_error(Puppet::ParseError, 'export_resources(): param type recieved String, expecting Hash.'))
  end

  it "should raise a ParseError if path is relative." do
    lambda { @scope.function_export_resources(['foo', 'bar', 'baz']) }.should( raise_error(Puppet::ParseError, 'export_resources(): path foo is not absolute.'))
  end

  it "should raise a Error if path is not a directory." do
    File.stubs(:exists?).with('/foo').returns true
    File.stubs(:directory?).with('/foo').returns false
    lambda { @scope.function_export_resources(['/foo', 'bar', {}]) }.should( raise_error(Puppet::Error, 'export_resource(): path /foo is not a directory.'))
  end

end
