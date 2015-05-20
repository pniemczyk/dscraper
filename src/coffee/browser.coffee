$ ->
  log = (msg) -> console.log(msg)
  class ExtractData
    default_shema_list:
      linkedin:
        fields:
          full_name:
            selector: '#name .full-name'
          headline:
            selector: '#headline .title'
          experience:
            block_list: true
            selector: '#background-experience .section-item'
            items:
              company:
                selector: 'h5'
              title:
                selector: 'h4'
              date:
                selector: 'span.experience-date-locale'
          summary:
            selector: '#background-summary'
          skils:
            collection: true
            selector: '#background-skills .skill-pill .endorse-item-name'
          interests:
            collection: true
            selector: '#interests .interests-listing li'
          languages:
            collection: true
            selector: '#background-languages .section-item'
          education:
            block_list: true
            selector: '#background-education-container .section-item'
            items:
              name:
                selector: 'h4'
              level:
                selector: 'h5'
              date:
                selector: '.education-date'

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
      chrome.runtime.sendMessage(@extId, {extId: @extId, method: "dscraperExtract", domain: domain, data: data})

    watch: ->
      chrome.runtime.onMessage.addListener((data, sender, sendResponse) ->
        profileUrl = data.request.url
        fields     = data.result
        html       = "<p><a href='#{profileUrl}'><b>Profile link</b></p></a><ul>"
        for field of fields
          content = if _.isString(fields[field])
            fields[field]
          else
            if _.isString(fields[field][0])
              fields[field].join(', ')
            else
              $.map(fields[field], (obj) ->
                itemHtml = '<ul>'
                for f of obj
                  itemHtml = itemHtml + "<li><b>#{f}:</b> #{obj[f]}</li>"
                itemHtml = itemHtml + '</ul>'
                itemHtml
              ).join('')
          html = html + "<li><b>#{field}:</b> #{content}</li>"
        html = html + '</ul>'
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
