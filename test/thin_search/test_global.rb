require 'test_helper'
require 'thin_search/global'


class TestGlobal < ::ThinSearch::Test
  def test_default_root_cwd
    assert_equal(Dir.pwd, ::ThinSearch::Global.default_root)
  end
end
