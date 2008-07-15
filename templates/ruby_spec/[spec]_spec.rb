require '../spec_helper.rb'

describe <%= "#{spec}_spec".camelize %> do
  it "flunks" do
    true.should be_nil
  end
end