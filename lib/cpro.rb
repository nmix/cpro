# frozen_string_literal: true

require 'dry-configurable'
require 'dry/core/class_attributes'
require 'open3'
require 'fileutils'

require 'cpro/version'
require 'cpro/cryptcp'

module Cpro
  class Error < StandardError; end
end
