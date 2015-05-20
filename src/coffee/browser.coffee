$ ->
  log = (msg) -> console.log(msg)
  class ExtractData
    default_shema_list:
      linkedin:
        fields:
          full_name: '#name .full-name'
          headline: '#headline .title'
          skils: '#background-skills-container .skills-section li'

        init_after: (data) ->
          arr = data['full_name'].split(' ')
          data['first_name'] = arr[0]
          data['last_name'] = arr[1]
          data

    constructor: (@schema_list = {}) ->

    schema: (name) ->
      @schema_list[name] || @default_shema_list[name] || {}

  class TableBuilder
    constructor: (@object) ->
    build: ->
      JSON.stringify(@object)

  class NaviView extends Backbone.View
    el: '#nav'

    initialize: (opts) ->
      @controller = opts.controller

    events:
      'click #nav_home':    'onClickHome'
      'click #nav_extract': 'onClickExtract'
      'click #nav_about':   'onClickAbout'
      'click #nav_contact': 'onClickContact'

    onClickHome:    => @controller.showPage('home')
    onClickAbout:   => @controller.showPage('about')
    onClickContact: => @controller.showPage('contact')
    onClickExtract: => @controller.showPage('extract')

  class PageController
    constructor: ->
      @extId       = chrome.runtime.id
      @navView     = new NaviView(controller: @)
      @extractData = new ExtractData()
      @watch()

    showPage: (pageName) =>
      $('.js-page-content').hide()
      @extract('linkedin.com', @extractData.schema('linkedin')) if pageName is 'extract'
      $("#page_#{pageName}").fadeIn()

    getTextFromSelector: (selector) ->
      chrome.extension.sendMessage({method: "getTextFromSelector", selector: selector}, (res) ->
        console.log(res)
      )

    localStorage: ->
      chrome.extension.sendMessage({method: "getLocalStorage", key: "name"}, (res) ->
        $('body').html(res)
        console.log(res)
      )

    extract: (domain, data) ->
      chrome.runtime.sendMessage(@extId, {extId: @extId, method: "dscraperExtract", domain: domain, data: data}, (res) ->
        console.log res
      )

    watch: ->
      chrome.runtime.onMessage.addListener((data, sender, sendResponse) ->
        profileUrl = data.request.url
        fields     = data.result
        log fields
        html       = '<ul>'
        for field of fields
          html = html + "<li><b>#{field}:</b> #{fields[field]}</li>"
        html = html + '</ul>'
        log html
        $('#page_extract_content').html(html)
      )

    # injectScript: (tab) ->
    #   chrome.tabs.executeScript(tab.id, {file: 'lib/js/inject.min.js'}, =>
    #     @getTextFromSelector('#name')
    #     # show('loading');
    #     # sendScrollMessage(tab);
    #   )
    # bal: (msg) -> chrome.tabs.executeScript(null, code:"alert('#{msg}');")
  new PageController()
