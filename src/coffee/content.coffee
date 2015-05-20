chrome.runtime.onMessage.addListener((request, sender, sendResponse) ->
  return null unless request.method is 'dscraperExtract'
  schema = request.data
  result   = {}
  for field of schema.fields
      result[field] = $.trim($(schema.fields[field]).text())
  sendResponse(result)
)
