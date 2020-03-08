# frozen_string_literal: true

module Cpro
  class Cryptcp
    extend Dry::Configurable
    extend Dry::Core::ClassAttributes

    HASH_ALGS = %i[gost_3411_94 gost3411_2012_256 gost3411_2012_512]

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
      # @return [String] хэш строки
      def hash(msg, opts = {})
      end
    end
  end
end
