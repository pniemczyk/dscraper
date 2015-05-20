chrome.runtime.onMessage.addListener((request, sender, sendResponse) ->
  return null unless request.method is 'dscraperExtract'
  chrome.tabs.query({active: true, currentWindow: true}, (tabs) =>
    activeTab = tabs[0]
    return null if activeTab.url.toLowerCase().indexOf(request.domain) < 0
    requestData     = request
    requestData.url = activeTab.url
    chrome.tabs.sendMessage(activeTab.id, requestData, (result) =>
      chrome.runtime.sendMessage(requestData.extId, {method: 'dscraperExtractResponse', request: requestData, result: result})
    )
  )
)
