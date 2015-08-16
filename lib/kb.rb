#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require 'mechanize'
require 'uri'
require 'open-uri'

class Kb
  def initialize(instance,uname,pword)
    @magent = Mechanize.new
    @instance = instance
    @uname = uname
    @pword = pword
    @base_url = "https://www.kbplus.ac.uk/"+instance
  end

  attr_accessor :instance, :org, :base_url, :org_base_url
  attr_reader :magent

  def login
    #@magent.ssl_version = 'SSLv3'
    @magent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @magent.follow_meta_refresh = true
    url = @base_url
    @magent.get(url) do |page|
      # Click the login link
      login_page = @magent.click(page.link_with(:text => /Knowledge Base\+ Member Login/))
      wayf = @magent.click(login_page.link_with(:text => /Let me choose from a list/))
      idp = wayf.form_with(:action => 'WAYF') do |wayf_f1|
        wayf_f1.field_with(:name => "origin").option_with(:value => "https://idp.edina.ac.uk/shibboleth").click
        ##<option value="https://idp.edina.ac.uk/shibboleth">EDINA (staff and trials)</option>
        #wayf_f1.SearchInput = "EDINA"
      end.click_button

      idp1 = idp.form_with(:action => '/shibboleth-idp/Authn/UserPassword') do |idp_f|
        idp_f.j_username = @uname
        idp_f.j_password = @pword
      end.click_button

      kb_dashboard = idp1.form_with(:action => 'https://www.kbplus.ac.uk/Shibboleth.sso/SAML2/POST') do |idp1_f|
      end.click_button
    end
  end

  def loginJisc
    @magent.follow_meta_refresh = true
    url = @base_url
    @magent.get(url) do |page|
      # Click the login link
      login_page = @magent.click(page.link_with(:text => /Knowledge Base\+ Member Login/))
      wayf = @magent.click(login_page.link_with(:text => /Let me choose from a list/))
      idp = wayf.form_with(:action => 'WAYF') do |wayf_f1|
        wayf_f1.field_with(:name => "origin").option_with(:value => "https://dlib-jiscidp.edina.ac.uk/idp/shibboleth").click
        ##<option value="https://idp.edina.ac.uk/shibboleth">EDINA (staff and trials)</option>
        #wayf_f1.SearchInput = "EDINA"
      end.click_button
      
      idp1 = idp.form_with(:action => '/idp/Authn/UserPassword') do |idp_f|
        idp_f.j_username = @uname
        idp_f.j_password = @pword
      end.click_button

      kb_dashboard = idp1.form_with(:action => 'https://www.kbplus.ac.uk/Shibboleth.sso/SAML2/POST') do |idp1_f|
      end.click_button
    end
  end

  def getpublicPackages
    url = @base_url + "/publicExport/idx?format=json"
    downloadjsoncontent = open(url)
    package_json = JSON.parse(File.read(downloadjsoncontent))
    return package_json
  end

  def checkPackage(package_name)
    url = @base_url + "/packageDetails/index"
    @magent.get(url) do |ps|
      ps_results = ps.form_with(:action => '/'+instance+'/packageDetails/index?max=10&offset=0') do |search|
        search.pkgname  = package_name.gsub(":", " ")
      end.click_button
      if (ps_results.link_with(:text => package_name))
        return "Indexed"
      else
        return "Not Indexed"
      end

    end
  end

  def updatePackagename(package_id,name)
    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "name",
      "value" => name,
      "pk" => "com.k_int.kbplus.Package:"+package_id.to_s})
  end

  def updatePackagepublic(package_id)
    url = @base_url + "/ajax/genericSetRel"
    page = @magent.post(url, {
      "name" => "isPublic",
      "value" => "com.k_int.kbplus.RefdataValue:108",
      "pk" => "com.k_int.kbplus.Package:"+package_id.to_s})
  end

  def updatePackageenddate(package_id,edate)
    begin 
      edate = DateTime.strptime(edate, '%Y-%m-%d')
    rescue
      puts "Invalid date: " + edate.to_s + ":" + package_id.to_s
      exit
    end
    url = @base_url + "/ajax/editableSetValue?type=date&format=yyyy%2FMM%2Fdd"
    page = @magent.post(url, {
      "name" => "endDate",
      "value" => edate,
      "pk" => "com.k_int.kbplus.Package:"+package_id.to_s})
  end

  def createSubscription(name,ref,sdate,edate)
    begin 
      sdate = DateTime.strptime(sdate, '%Y-%m-%d')
      edate = DateTime.strptime(edate, '%Y-%m-%d')
    rescue
      puts "Invalid dates"
      exit
    end
    if (@org)
      @org_base_url = @base_url + "/myInstitutions/" + @org
      url = @org_base_url + "/processEmptySubscription"
      page = @magent.post(url, {
        "newEmptySubName" => name.to_s,
        "newEmptySubId" => ref.to_s,
        "valid_from" => sdate,
        "valid_to" => edate
      })
      return page.uri.to_s
    else
      puts "No organisation specified, cannot create Subscription"
    end
  end

  def linkPackage(subid,packageid,entitlementswitch)
    if(entitlementswitch == "With" || entitlementswitch == "Without")
      url = @base_url + "/subscriptionDetails/linkPackage/" +subid.to_s + "?addId=" + packageid.to_s + "&addType=" + entitlementswitch.to_s
      @magent.get(url)
      return true
    else
      return false
    end
  end

  def createOrganisation(name,sector)
    url = @base_url + "/org/create"
    page = @magent.post(url, {
      "name" => name,
      "sector" => sector
      })
  end

  def updateOrganisation(id,address=false,iprange=false,sector=false,name=false)
    url = @base_url + "/org/edit/" + id.to_s
    @magent.get(url) do |org_edit|
      update_org =  org_edit.form_with(:action => '/'+instance+'/org/edit/'+id.to_s)
      if (name)
        update_org["name"] = name.to_s
      end
      if (iprange)
        update_org.ipRange = iprange.to_s
      end
      if (sector)
        update_org.sector = sector.to_s
      end
      if (address)
        update_org.address = address.to_s
      end
      update = update_org.submit
    end
  end

  def checkInstitution(shortcode)
    url = @base_url + "/myInstitutions/" + shortcode + "/dashboard"
    begin
      page = @magent.head(url)
      if page.code.to_i == 200
        return true
      else
        return false
      end
    rescue Exception => e
      return false
    end
  end

  def joinOrg(org,role)
    #/kbplus/profile/processJoinRequest/affiliationRequestForm
    #post
    url =  @base_url + "/profile/processJoinRequest/affiliationRequestForm"
    page = @magent.post(url, {
      "org" => org.to_s,
      "formalRole" => role #5 = institutional editor, 6 = Read only
      })
  end

  def approveAffiliation(name)
    url = @base_url + "/admin/manageAffiliationRequests"
    page = @magent.get(url)
    #search through page to find table row containing name
    row_count = 0
    page.search('//tr').each do |row|
        row.search('td[4]/text()').each do |a|
          puts a.to_s
        end
        row.search('td[2]/text()').each do |col|
            puts row_count
            puts col.to_s
            if (col.to_s==name)
              @magent.page.links_with(:text => /Approve/)[row_count].click
              sleep(2)
              puts "Clicked"
            end
            row_count += 1
        end
    end
  end

  def updateTIPPstart(tipp_id,sdate,svol,siss)
    url = @base_url + "/ajax/editableSetValue?type=date&format=yyyy%2FMM%2Fdd"
    page = @magent.post(url, {
      "name" => "startDate",
      "value" => sdate,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})

    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "startVolume",
      "value" => svol,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})

    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "startIssue",
      "value" => siss,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})
  end

  def updateTIPPend(tipp_id,edate,evol,eiss)
    url = @base_url + "/ajax/editableSetValue?type=date&format=yyyy%2FMM%2Fdd"
    page = @magent.post(url, {
      "name" => "endDate",
      "value" => edate,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})

    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "endVolume",
      "value" => evol,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})

    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "endIssue",
      "value" => eiss,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})
  end

   def updateTIPPcoverage(tipp_id,coverage,coveragenote)
    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "coverageDepth",
      "value" => coverage,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})

    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "coverageNote",
      "value" => coveragenote,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})
  end

  def updateTIPPhosturl(tipp_id,hurl)
    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "hostPlatformURL",
      "value" => hurl,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})
  end

  def makeTIPPOA(tipp_id)
    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "payment",
      "value" => "com.k_int.kbplus.RefdataValue:236",
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})
  end


  def softdeleteTipp(tipp_id)
    url = @base_url + "/ajax/genericSetRel"
    softdelete = "com.k_int.kbplus.RefdataValue:113"
    page = @magent.post(url, {
      "name" => "status",
      "value" => softdelete,
      "pk" => "com.k_int.kbplus.TitleInstancePackagePlatform:"+tipp_id.to_s})
  end

  def getTiTitle(ti_id)
    url = @base_url + "/titleDetails/show/" + ti_id
    ti_title = @magent.get(url).search("h1").inner_text
    return ti_title
  end

  def updateTiTitle(ti_id,title)
    url = @base_url + "/ajax/editableSetValue"
    page = @magent.post(url, {
      "name" => "title",
      "value" => title,
      "pk" => "com.k_int.kbplus.TitleInstance:"+ti_id.to_s})
  end

  def mergeTiTitle(ti_deprecate,ti_correct)
    url = @base_url + "/admin/titleMerge?titleIdToDeprecate=" + ti_deprecate + "&correctTitleId=" + ti_correct + "&MergeButton=Go"
    page = @magent.get(url)
    return page.uri.to_s
  end

  def removeIdsfromTI(ti_id)
    url = @base_url + "/titleDetails/edit/" + ti_id
    page = @magent.get(url)
    while(@magent.page.links_with(:text => /Delete Identifier/).length>0)
      del_id = @magent.page.links_with(:text => /Delete Identifier/)[0]
      page = del_id.click
      sleep(2)
      puts "Deleted identifier: " + del_id.href
    end
    puts "No identifiers"
  end


   def createLicence(lic_name)
    url = @base_url + "/licenseDetails/processNewTemplateLicense"
    page = @magent.post(url, {
      "reference" => lic_name.to_s
      })
    return page.uri.to_s
  end

  def updateRemoteAccessNote(lic_id,value)
    url = @base_url + "/ajax/setFieldTableNote/" + lic_id.to_s + "?type=License"
    puts url
    page = @magent.post(url, {
      "name" => "remoteAccess",
      "value" => value,
      "pk" => "com.k_int.kbplus.License:"+lic_id.to_s+"S"
      })
    pp page
  end

  def ennumeratePackagesforTitle(ti_id)
    url = @base_url + "/titleDetails/show/" + ti_id.to_s
    @magent.get(url) do |tid|
      tid.search('//form/table/tr').each do |row|
        row.search('td[3]/a/@href').each do |col|
            puts col.to_s
        end
      end
    end
  end

  def getTIPPfromTI(ti_id,package_id)
    begin
      url = @base_url + "/titleDetails/show/" + ti_id.to_s
    rescue
      return false
    end
    @magent.get(url) do |tid|
      tid.search('//form/table/tr').each do |row|
        if (row.search('td[3]/a/@href').to_s == "/"+instance+"/packageDetails/show/" + package_id[0])
          return row.search('td[1]/input/@name').to_s.tr("_bulkflag.","")
        else
          next
        end
      end
    end
  end

  def getTIPPsfromTI(ti_id)
    tipps = Array.new()
    begin
      url = @base_url + "/titleDetails/show/" + ti_id.to_s
    rescue
      return false
    end
    @magent.get(url) do |tid|
      tid.search('//form/table/tr').each do |row|
        if (row.search('td[7]/a/text()').to_s == "Full TIPP record")
          tipps.push(row.search('td[1]/input/@name').to_s.tr("_bulkflag.",""))
        else
          next
        end
      end
      return tipps
    end
  end

  def proposeTI(ti_title)
    url = @base_url + "/titleDetails/findTitleMatches?proposedTitle=" + ti_title
    page = @magent.get(url)
    #search through page to find "There were no matches for the title string" within a div with 'alert' class
    return page.parser.css('div.alert').text.include? 'There were no matches for the title string'
  end

  def createTI(ti_title)
    url = @base_url + "/titleDetails/createTitle?title=" + ti_title
    page = @magent.get(url)
    return page.uri.to_s
  end

  def createTIPP(ti_id,package_id,platform_id)
    url = @base_url + "/ajax/addToCollection"
    page = @magent.post(url, {
      "__context" => "com.k_int.kbplus.Package:"+package_id,
      "__newObjectClass" => "com.k_int.kbplus.TitleInstancePackagePlatform",
      "__recip" => "pkg",
      "status" => "com.k_int.kbplus.RefdataValue:29",
      "title" => "com.k_int.kbplus.TitleInstance:"+ti_id,
      "platform" => "com.k_int.kbplus.Platform:"+platform_id})
  end

  def uploadPackage(file)
    url = @base_url + "/upload/reviewPackage"
    page = @magent.post(url, {
      "soFile" => file,
      "OverrideCharset" => 'on',
      "docstyle" => 'csv'
      })
    if(page.parser.css('a').text.include? 'New Package Details')
      return page.parser.xpath("//a[text()='New Package Details']/@href").to_s
    else
      return false
    end
  end

  def addIE(sub_id,tipp_id)
    url = @base_url + "/subscriptionDetails/processAddEntitlements"
    flag = "_bulkflag." + tipp_id.to_s
    page = @magent.post(url, {
      "siid" => sub_id,
      flag => 'on'
      })
  end

  def removeCoreend(coreassert)
    url = @base_url + "/ajax/editableSetValue?type=date&format=yyyy%2FMM%2Fdd"
    page = @magent.post(url, {
      "name" => "endDate",
      "value" => "",
      "pk" => "com.k_int.kbplus.CoreAssertion:"+coreassert.to_s})
  end

end