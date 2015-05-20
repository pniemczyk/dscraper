log = (m) -> console.log m
chrome.runtime.onMessage.addListener((request, sender, sendResponse) ->
  return null unless request.method is 'dscraperExtract'
  schema = request.data
  result   = {}
  for field of schema.fields
    current = schema.fields[field]
    if current.collection
      result[field] = $(current.selector).map(-> $.trim($(@).text())).get()
    if current.block_list
      result[field] = $(current.selector).map( ->
        item = {}
        for f of current.items
          el = $(@).find(current.items[f].selector)
          item[f] = $.trim($(el).text())
        item
      ).get()
    unless result[field]
      result[field] = $.trim($(current.selector).text())
  sendResponse(result)
)
