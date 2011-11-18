# 
# test_link_link.rb
# 
# Author : Mitsuyoshi Yoshida
# This program is freely distributable under the terms of an MIT-style license.
# 

require 'i18n'


class TestLinkKeyInfo
  attr_reader :idno, :formatno, :enable_formats

  def initialize(linkstrs, idno=1, formatno=nil, enable_formats = nil)
    @linkstrs = linkstrs
    @idno = idno
    @formatno = formatno
    @enable_formats = enable_formats
  end

  def linkstr(key)
    ver = Setting.plugin_redmine_testlinklink["testlink_version"]
    verid = nil
    case ver
    when '1.7'
      verid = 0
    when '1.8'
      verid = 1
    end
    str = @linkstrs[verid]
    raise sprintf(I18n.t('error.miss_ver'), key, ver)	unless str
    str
  end

end



class TestLinkLink

  private
  
  KeyTable = {
    'case' => TestLinkKeyInfo.new(['testcases/archiveData.php?version_id=undefined&edit=testcase&id=%s',
                                   'testcases/archiveData.php?targetTestCase=%s&edit=testcase']),
    'suite' => TestLinkKeyInfo.new(['testcases/archiveData.php?edit=testsuite&id=%s',
                                   'testcases/archiveData.php?print_scope=test_specification&edit=testsuite&level=testsuite&id=%s']),
    'project' => TestLinkKeyInfo.new([nil, 'project/projectEdit.php?doAction=edit&tprojectID=%s']),
    'plan' => TestLinkKeyInfo.new(['plan/planEdit.php?tplan_id=%s&do_action=edit',
                                   'plan/planEdit.php?do_action=edit&tplan_id=%s']),
    'milestone' => TestLinkKeyInfo.new(['plan/planMilestones.php?id=%s',
                                       'plan/planMilestonesEdit.php?doAction=edit&id=%s']),
    'build' => TestLinkKeyInfo.new(['plan/buildNew.php?do_action=edit&build_id=%s', 
                                    'plan/buildEdit.php?do_action=edit&build_id=%s']),
    'cfield' => TestLinkKeyInfo.new(['cfields/cfields_edit.php?do_action=edit&cfield_id=%s',
                                     'cfields/cfieldsEdit.php?do_action=edit&cfield_id=%s']),
    'keyword' => TestLinkKeyInfo.new(['keywords/keywordsView.php?id=%s',
                                     'keywords/keywordsEdit.php?doAction=edit&id=%s']),
    'user' => TestLinkKeyInfo.new(['usermanagement/usersedit.php?user_id=',
                                   'usermanagement/usersEdit.php?doAction=edit&user_id=%s']),
    'planreport' => TestLinkKeyInfo.new([nil, 'results/printDocument.php?level=testsuite&id=%s&type=testplan&docTestPlanId=%s'],
                                        2, 0, [1, 4]),
    'report' => TestLinkKeyInfo.new([nil, 'results/printDocument.php?level=testsuite&id=%s&type=testreport&docTestPlanId=%s'],
                                    2, 0, [1, 4]),
    'metrics' => TestLinkKeyInfo.new([nil, 'results/resultsGeneral.php?&tplan_id=%s'], 1, 0, [2,3]),
    'result' => TestLinkKeyInfo.new([nil, 'results/resultsTC.php?&tplan_id=%s'], 1, 0, [2,3]),
    'graph' => TestLinkKeyInfo.new([nil, 'results/charts.php?&tplan_id=%s'], 1, 0)
  }
  DefaultArgs = {
    "planreport" => ['summary'],
    "report" => ['summary', 'passfail']
  }
  FormatNameTable = {
    'odt' => 1,
    'ods' => 2,
    'xls' => 3,
    'doc' => 4
  }

  def default_output_items(key)
    out = []
    reg = /^default_#{key}_(\w+)$/
    Setting.plugin_redmine_testlinklink.each {|key, val|
      if ((key =~ reg) and val)
        out << $1
      end
    }
    out
  end
  
  public
  
  def initialize(*args)
    @ids = []
    @key = nil
    @restargs = []
    @keyinfo = nil
    @isdl = nil
    @formatno = nil
    @formatname = nil
    args.each {|arg|
      val = nil
      if arg
        val = arg.strip
        val = nil 	if val.empty?
      end
      if (!@key)
        @key = val
        raise I18n.t('error.no_key')	unless val
        @keyinfo = KeyTable[val]
        unless @keyinfo
          raise I18n.t('error.invalid_key')
        end
        @formatno = @keyinfo.formatno
      elsif (@ids.size < @keyinfo.idno)
        raise I18n.t('error.no_id')	unless val
        @ids << val
      else
        @restargs << val	if val
      end
    }
  end


  def formatname=(fmtname)
    fmtno = FormatNameTable[fmtname]
    unless fmtno
      raise sprintf(I18n.t('error.invalid_fmt'), fmtname, FormatNameTable.keys.join(','))
    end
    unless @keyinfo.enable_formats.include?(fmtno)
      raise sprintf(I18n.t('error.not_report'), fmtname)
    end
    @formatno = fmtno
    @formatname = fmtname
  end

  
  def link
    idstr = @ids.join('-')
    viewstr = "TestLink:#{@key}##{idstr}"
    if (0 < @restargs.size)
      viewstr += "(#{@restargs.join(', ')})"
    end
    linkstr = sprintf(@keyinfo.linkstr(@key), *@ids)
    if (@keyinfo.idno == 2)
      args = default_output_items(@key) + @restargs
      linkstr += '&' + args.uniq.map{|e| e + '=y'}.join('&')
    elsif (@key == 'result' and (0 < @restargs.size))
      linkstr.gsub!('resultsTC', 'resultsByStatus')
      linkstr += '&type=' + @restargs[0]
    end
    linkstr += '&' + "format=#{@formatno}"	if @formatno

    linkstr = "lib/" + linkstr
    linkstr = File.join(Setting.plugin_redmine_testlinklink["testlink_address"], linkstr)

    windowstr = "target='_blank'"
    if (@formatname)
      windowstr = ""
      viewstr += ":#{@formatname}"
    end
    
    "<a class='testlinklink' href='#{linkstr}' #{windowstr}>#{viewstr}</a>"
  end
  

end
