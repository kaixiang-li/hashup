require_relative 'spec_helper'
require 'fileutils'

describe Hashup::Generator, "setup site" do
  it "creates the static sites layout structure" do
    generator = Hashup::Generator.new  
    generator.setup "test_project"
    (Dir.exists? "test_project").should == true
    FileUtils.rm_rf 'test_project'
  end
end
