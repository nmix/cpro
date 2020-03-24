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

      it { expect(subject.first).to end_with('/opt/cprocsp/bin/amd64/cryptcp') }

      it { expect(subject[1]).to be_nil }

      it { expect(subject[2]).to eq('-hashAlg 1.2.643.7.1.1.2.2') }
    end

    context 'with cryptcp_bin_dir opt' do
      let(:opts) { { cryptcp_bin_dir: '/usr/local/bin' } }

      it { expect(subject.first).to end_with('/usr/local/bin/cryptcp') }
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

      it { expect { subject[2] }.to raise_error(Cpro::Error) }
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
    subject { described_class.hash('asd', opts) }

    after { FileUtils.rm_rf tmp_dir }

    context 'with default opts' do
      let(:opts) { {} }

      it { expect(subject).to eq('618A785A263348C15CA46D939105EBA105359DD3B84991190480B2F47405967D') }
    end

    context 'with hash_alg gost3411_94' do
      let(:opts) { { hash_alg: :gost3411_94 } }

      it { expect(subject).to eq('3C1C898C128E3C5A764D2E6A0071BADE79370D3531B501E06D56FA2DFD480BD3') }
    end
    

    context 'with hash_alg gost3411_2012_256' do
      let(:opts) { { hash_alg: :gost3411_2012_256 } }

      it { expect(subject).to eq('618A785A263348C15CA46D939105EBA105359DD3B84991190480B2F47405967D') }
    end

    context 'with hash_alg gost3411_2012_512' do
      let(:opts) { { hash_alg: :gost3411_2012_512 } }

      it { expect(subject).to eq('39D19C0D5879304D640712996693798C4F33C4260D0F8C5D06A5FDC81AD891A9220B04A9A17CDF63EDCA856452FABC632671FC623A492444E47E7F9610DEB0A9') }
    end
  end

  describe '.sign' do
    subject { described_class.sign('hello world', opts) }

    after { FileUtils.rm_rf tmp_dir }

    context 'with dn option' do
      let(:opts) { { dn: { CN: 'Иван Иванов' }, debug: true } }

      it { expect(subject).to end_with('/opt/cprocsp/bin/amd64/cryptcp -dn "CN=Иван Иванов" -hashAlg 1.2.643.7.1.1.2.2 -sign -dir /tmp/cpro-test -provtype 80 -detach /tmp/cpro-test/pfile-1') }
    end

    context 'with detach option' do
      let(:opts) { { detach: false, debug: true } }

      it { expect(subject).to end_with('/opt/cprocsp/bin/amd64/cryptcp -hashAlg 1.2.643.7.1.1.2.2 -sign -dir /tmp/cpro-test -provtype 80 /tmp/cpro-test/pfile-1') }
    end

    context 'with pin option' do
      let(:opts) { { pin: '123', debug: true } }

      it { expect(subject).to end_with('/opt/cprocsp/bin/amd64/cryptcp -hashAlg 1.2.643.7.1.1.2.2 -sign -dir /tmp/cpro-test -provtype 80 -detach -pin 123 /tmp/cpro-test/pfile-1') }
    end
  end
end
