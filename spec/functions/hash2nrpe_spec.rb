require 'spec_helper'

describe 'nrpe::hash2nrpe' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('1', '2').and_raise_error(ArgumentError) }

  it do
    is_expected.to run.with_params({'foo' => 1}).and_return('foo=1')
  end
  it do
    is_expected.to run.with_params({'foo' => 0}).and_return('foo=0')
  end
  it do
    is_expected.to run.with_params({'foo' => true}).and_return('foo=1')
  end
  it do
    is_expected.to run.with_params({'foo' => false}).and_return('foo=0')
  end
  it do
    is_expected.to run.with_params({'foo' => ['a','b','c']}).and_return('foo=a,b,c')
  end
  it do
    is_expected.to run.with_params({'foo' => 'i <3 spaces'}).and_return('foo="i <3 spaces"')
  end
  it do
    is_expected.to run.with_params({'foo' => nil}).and_return('')
  end
  it do
    is_expected.to run.with_params({'foo' => false, 'bar' => 1}).and_return("bar=1\nfoo=0")
  end
end
