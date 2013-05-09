require_relative 'spec_helper'

describe Hashup::Site, "index template" do
  it "creates a slim template for site index" do
    Dir.chdir("lib/hashup/templates")    
    site = Hashup::Site.new
    site.configs.should_not == nil
  end


end

