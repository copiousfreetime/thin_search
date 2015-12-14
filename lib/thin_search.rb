module ThinSearch
  VERSION = "0.4.2"

  class Error < ::StandardError ; end
end

require 'thin_search/document'
require 'thin_search/conversion'
require 'thin_search/indexable'
require 'thin_search/store'
require 'thin_search/index'
