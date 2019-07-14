#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:dhcp_host) do
  let(:catalog) { Puppet::Resource::Catalog.new }

  it 'check with default parameters list' do
    params = {
      title: 'namevar',
      catalog: catalog
    }
    expect { described_class.new(params) }.not_to raise_error
  end
end
