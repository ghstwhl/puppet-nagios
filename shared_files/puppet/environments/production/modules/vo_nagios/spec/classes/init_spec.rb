require 'spec_helper'
describe 'vo_nagios' do

  context 'with defaults for all parameters' do
    it { should contain_class('vo_nagios') }
  end
end
