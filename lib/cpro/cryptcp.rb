# frozen_string_literal: true

module Cpro
  class Cryptcp
    extend Dry::Configurable
    extend Dry::Core::ClassAttributes

    HASH_ALGS = %i[gost_3411_94 gost3411_2012_256 gost3411_2012_512]

    # директория для временных файлов
    setting :cpro_tmp_dir, '/tmp/cpro'
    # базовое имя pipe-файла
    setting :pipe_basename, 'pfile'
    # директория с исполняемым файлом cryptcp
    setting :cryptcp_bin_dir, '/opt/cprocsp/bin/amd64'
    # параметры поиска сертификата
    setting :dn, {}
    # алгоритм хэширования
    setting :hash_alg, HASH_ALGS[1]

    class << self
      # Функция хэширования строки
      # @param msg [String] строка, хэш которой определяем
      # @param opts [Hash] опции метода
      # @option opts [Hash] :dn параметры поиска сертификата
      # @option opts [Symbol] :hash_alg алгоритм хэширования,
      #   варианты HASH_ALGS
      # @option opts [bool] :debug отладочный вывод команды. Команда
      #   не исполняется
      # @return [String/nil] хэш строки
      def hash(msg, opts = {})
        hash_cmd = argv.push(
          '-hash',
          '-hex',
          "-dir #{config.cpro_tmp_dir}",
          mk_pipe_file
        ).join(' ')
        if opts.key?(:debug) && opts[:debug] == true
          puts hash_cmd
          return
        end

        system_call(msg, 'hsh') do
          stdout, stderr, status = Open3.capture3(hash_cmd)
        end
      end

      # Вызов системной команды с работой через pipe-файлы
      # @param msg [String] контент входного файла 
      # @param ext [String] расширение для выходного файла
      # @note обычно выходной файл получается путем добавления
      #   расширения к входному файлу
      # @yield блок для команды
      # @return [String] содержание выходного файла
      def system_call(msg, ext = nil)
        input_pipe_file = mk_pipe_file
        input_thr = Thread.new do
          File.open(input_pipe_file, 'w') { |f| f.write(msg) }
        end

        output_pipe_file = mk_pipe_file(ext: ext)
        output_thr = Thread.new do
          File.open(output_pipe_file, 'r') { |f| f.read }
        end

        yield if block_given?
        
        input_thr.join
        output_thr.join
        output_thr.value
      end

      # Создание pipe-файла для работы с командами КриптоПро
      # @param opts [Hash] опции метода
      # @option opts [String] :ext расширение для pipe-файла 
      # @return [String] путь к pipe-файлу
      def mk_pipe_file(opts = {})
        tmp_dir = config.cpro_tmp_dir
        FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)
        ext = opts.compact.key?(:ext) ? ".#{opts[:ext]}" : ''
        pipe_basename = "#{config.pipe_basename}-#{pid}#{ext}"
        pipe_fullname = File.join(tmp_dir, pipe_basename)
        File.mkfifo(pipe_fullname) unless File.exist?(pipe_fullname)
        pipe_fullname
      end

      # Ид-р текущего процесса
      # @return [Integer]
      def pid
        Process.pid
      end

      # Команда и атрибуты
      # @param opts [Hash] опции метода
      # @return [Array]
      def argv(opts = {})
        # --- cryptcp cmd
        cmd = if opts.key?(:cryptcp_bin_dir)
                File.join(opts[:cryptcp_bin_dir], 'cryptcp')
              else
                File.join(config.cryptcp_bin_dir, 'cryptcp')
              end

        # --- dn option
        dn_hash = opts.key?(:dn) ? opts[:dn] : config.dn
        dn = if dn_hash.nil? || dn_hash.empty?
               nil
             else
               dn_vals = dn_hash.map{ |k,v| "#{k}=#{v}" }.join(',')
               "-dn \"#{dn_vals}\""
             end

        # --- hashAlg option
        hash_alg_opt = opts.key?(:hash_alg) ? opts[:hash_alg] : config.hash_alg
        raise ArgumentError, "unknown hash_alg :#{hash_alg_opt}" \
          unless HASH_ALGS.include?(hash_alg_opt)

        hash_alg_oid = if hash_alg_opt == :gost_3411_94
                        '1.2.643.2.2.9'
                      elsif hash_alg_opt == :gost3411_2012_256
                        '1.2.643.7.1.1.2.2'
                      else
                        '1.2.643.7.1.1.2.3'
                      end
        hash_alg = "-hashAlg #{hash_alg_oid}"

        [cmd, dn, hash_alg]
      end
    end
  end
end
