RSpec.describe Cpro::Cryptcp do
  describe '.config' do
    subject { described_class.config }

    context 'with default values' do
      it { expect(subject.dn).to eq({}) }

      it { expect(subject.hash_alg).to eq(:gost3411_2012_256) }

      it { expect(subject.cryptcp_bin_dir).to eq('/opt/cprocsp/bin/amd64') }
    end
  end
end
