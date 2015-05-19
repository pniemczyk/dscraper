$ ->
  class Extractor
    default_shema_list:
      linkedin:
        fields:
          full_name:
            selector: '#name'
        init_after: (data) ->
          arr = data['full_name'].split(' ')
          data['first_name'] = arr[0]
          data['last_name'] = arr[1]
          data

    constructor: (@schema_list = {}) ->

    extract: (name, dom) ->
      schema = @schema_list[name] || @default_shema_list[name]
      null unless schema
      data = {}
      for field of schema.fields
          data[field] = $.trim($(schema.fields[field].selector).text())
      schema.init_after(data)

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
      @navView = new NaviView(controller: @)

    showPage: (pageName) =>
      $('.js-page-content').hide()
      @extractInit() if pageName is 'extract'
      $("#page_#{pageName}").fadeIn()


    extractInit: =>
      chrome.tabs.getSelected null, (tab) =>
        @extractLinkedIn(tab) if tab.url.toLowerCase().indexOf('linkedin.com') > 0
    extractLinkedIn: (tab) ->
      chrome.pageCapture.saveAsMHTML({tabId: tab.id}, (mhtml) ->
        reader = new FileReader()
        reader.addEventListener("loadend", (e) ->
          console.log e.srcElement.result
        )
        reader.readAsText(mhtml)
        false
      )
      # chrome.tabs.executeScript(null, code:"alert('extract');")
  new PageController()
