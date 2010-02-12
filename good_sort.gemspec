# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{good_sort}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason King"]
  s.date = %q{2010-02-12}
  s.email = %q{jk@silentcow.com}
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.files = ["README.markdown", "VERSION.yml", "lib/good_sort", "lib/good_sort/sorter.rb", "lib/good_sort/view_helpers.rb", "lib/good_sort/will_paginate.rb", "lib/good_sort.rb", "test/sorter_test.rb", "test/view_helpers_test.rb", "test/test_helper.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/JasonKing/good_sort}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
