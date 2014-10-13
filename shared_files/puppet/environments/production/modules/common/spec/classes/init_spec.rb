require 'spec_helper'
describe 'common' do

  context 'with defaults for all parameters' do
    it { should contain_class('common') }
  end
end
