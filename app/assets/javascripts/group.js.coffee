scrollToItem = (groupId) ->
  if groupId
    elem = $("tr[data-group-id=" + groupId + "]")
    $("html, body").animate({
      scrollTop: $(elem).offset().top - $("div.container.nav-collapse").height()
    }, 0) if elem.length > 0

$ ->
  if $("div#groups-index").length > 0
    groupId = window.location.hash.replace("#", "")
    scrollToItem(groupId)
