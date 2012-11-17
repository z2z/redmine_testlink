
require 'redmine'
require_dependency 'testlinklink_asset_tag_helper_patch'
require_dependency 'testlinklink_view_layouts_base_html_head_hook'

Redmine::Plugin.register :redmine_testlinklink do
  name 'Testlink Link plugin'
  author 'M. Yoshida'
  description 'Links the test case, the project and so on from Redmine to TestLink.'
  version '1.0.0(beta)'
  url 'http://www.r-labs.org/projects/rp-testlinklink/wiki/TestLinkLinkEn'
  author_url 'http://yohshiy.blog.fc2.com/'
  requires_redmine :version_or_higher => '2'

  settings :default => {
    'testlink_address' => 'http://localhost/testlink',
    'testlink_version' => '1.8',
    'default_report_toc' => false,
    'default_report_header' => false,
    'default_report_summary' => 1,
    'default_report_body' => false,
    'default_report_author' => false,
    'default_report_keyword' => false,
    'default_report_cfields' => false,
    'default_report_passfail' => 1,
    'default_report_metrics' => false,
    'default_planreport_toc' => false,
    'default_planreport_header' => false,
    'default_planreport_summary' => 1,
    'default_planreport_body' => false,
    'default_planreport_author' => false,
    'default_planreport_keyword' => false,
    'default_planreport_cfields' => false,
    'default_planreport_testplan' => false
  }, :partial => 'settings/testlinklink_settings'
end


Redmine::WikiFormatting::Macros.register do
  desc "TestLink link macro"
  macro :testlink do |obj, args|
    tl = TestLinkLink.new(*args)
    tl.link
  end
end

Redmine::WikiFormatting::Macros.register do
  desc "TestLink TestCase link macro"
  macro :testcase do |obj, args|
    tl = TestLinkLink.new('case', *args)
    tl.link
  end
end

Redmine::WikiFormatting::Macros.register do
  desc "TestLink TestReport link macro"
  macro :testreport do |obj, args|
    tl = TestLinkLink.new('report', *args)
    tl.link
  end
end


Redmine::WikiFormatting::Macros.register do
  desc "TestLink TestFile link macro"
  macro :testfile do |obj, args|
    fmtname = args.shift
    tl = TestLinkLink.new(*args)
    tl.formatname = fmtname
    tl.link
  end
end
