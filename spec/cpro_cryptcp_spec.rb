RSpec.describe Cpro::Cryptcp do
  let(:tmp_dir) { '/tmp/cpro-test' }

  before do
    allow(Cpro::Cryptcp).to receive(:pid).and_return(1)
    Cpro::Cryptcp.config.cpro_tmp_dir = tmp_dir
  end

  describe '.config' do
    subject { described_class.config }

    context 'with default values' do
      it { expect(subject.dn).to eq({}) }

      it { expect(subject.hash_alg).to eq(:gost3411_2012_256) }

      it { expect(subject.cryptcp_bin_dir).to eq('/opt/cprocsp/bin/amd64') }
    end
  end

  describe '.argv' do
    subject { described_class.argv(opts) }

    context 'with default values' do
      let(:opts) { {} }

      it { expect(subject.first).to eq('/opt/cprocsp/bin/amd64/cryptcp') }

      it { expect(subject[1]).to be_nil }

      it { expect(subject[2]).to eq('-hashAlg 1.2.643.7.1.1.2.2') }
    end

    context 'with cryptcp_bin_dir opt' do
      let(:opts) { { cryptcp_bin_dir: '/usr/local/bin' } }

      it { expect(subject.first).to eq('/usr/local/bin/cryptcp') }
    end

    context 'with dn opt' do
      let(:opts) { { dn: { CN: 'Иван Иванов', E: 'ivanoff@example.com' } } }

      it { expect(subject[1]).to eq('-dn "CN=Иван Иванов,E=ivanoff@example.com"') }
    end

    context 'with hash_alg opt' do
      let(:opts) { { hash_alg: :gost3411_2012_512 } }

      it { expect(subject[2]).to eq('-hashAlg 1.2.643.7.1.1.2.3') }
    end

    context 'with raised hash_alg opt' do
      let(:opts) { { hash_alg: :gost3411_2012_1024 } }

      it { expect { subject[2] }.to raise_error(ArgumentError) }
    end
  end

  describe '.mk_pipe_file' do
    subject { described_class.mk_pipe_file(opts) }

    after { FileUtils.rm_rf tmp_dir }

    context 'without opts' do
      let(:opts) { {} }

      it { expect(subject).to eq('/tmp/cpro-test/pfile-1') }

      it 'has a pipe' do
        subject
        expect(File.pipe?('/tmp/cpro-test/pfile-1')).to be(true)
      end
    end

    context 'with ext option' do
      let(:opts) { { ext: 'hsh' } }

      it { expect(subject).to eq('/tmp/cpro-test/pfile-1.hsh') }

      it 'has a pipe' do
        subject
        expect(File.pipe?('/tmp/cpro-test/pfile-1.hsh')).to be(true)
      end
    end
  end

  describe '.system_call' do
    subject { described_class.system_call('hello world') { `echo a` } }

    after { FileUtils.rm_rf tmp_dir }

    it 'has a pipe' do
      subject
      expect(File.pipe?('/tmp/cpro-test/pfile-1')).to be(true)
    end

    it { expect(subject).to eq('hello world') }
  end

  describe '.hash' do
    subject { described_class.hash('asd') }

    it { expect(subject).to eq('618A785A263348C15CA46D939105EBA105359DD3B84991190480B2F47405967D') }
  end
end
