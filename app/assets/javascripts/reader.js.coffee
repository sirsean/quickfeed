currentVersion = null
groups = null
currentGroup = null
items = null
currentItem = null
selectedItem = null

versionMismatch = () ->
    console.log("version mismatch")
    $("#version-mismatch").show()
    $("a").unbind("click")
    $("a").click((event) ->
        event.preventDefault()
    )

window.quickfeed.loadGroups = () -> $.ajax "/api/groups.json",
    type: "GET",
    dataType: "json",
    error: (xhr, status, error) ->
        console.log(xhr)
        console.log(status)
        console.log(error)
    success: (data, status, xhr) ->
        console.log(data)
        if currentVersion == null
          currentVersion = data.version
        groups = data.groups
        consolidateGroup group for group in groups
        console.log(currentGroup)
        if groups.length == 0
          $("#noGroupsModal").modal()
          $("div#items div#groupButtons").hide()
        else
          unreadGroups = groupsWithUnreadItems()
          if unreadGroups.length == 0
            $("div#items div#noItems").show()
            $("div#items div#groupButtons").hide()
          else
            $("div#items div#noItems").hide()
            if currentGroup == null && unreadGroups.length > 0
              selectGroup(unreadGroups[0])
        if currentVersion != data.version
          versionMismatch()

window.quickfeed.loadItems = (groupId) -> 
    $("div#items").hide()
    $("div#items-loading").show()
    $("div#items ul").empty()
    $.ajax "/api/items.json",
    type: "GET",
    dataType: "json",
    data: {groupId: groupId},
    error: (xhr, status, error) ->
        console.log(xhr)
        console.log(status)
        console.log(error)
    success: (data, status, xhr) ->
        console.log(data)
        $("div#items ul").empty()
        $("div#items-loading").hide()
        $("div#items").show()
        items = data.items
        consolidateItem item for item in items
        consolidateMoreButton(data.num_items)

loadMoreItems = () ->
    $.ajax "/api/items.json",
    type: "GET",
    dataType: "json",
    data: { groupId: currentGroup.id, lastItemId: items[items.length-1].id },
    success: (data, status, xhr) ->
        console.log(data)
        items = items.concat(data.items)
        console.log(items)
        consolidateItem item for item in data.items
        consolidateMoreButton(data.num_items)

readItem = (item) -> 
    if item.unread
      $.ajax "/api/read_item.json",
        type: "POST",
        dataType: "json",
        data: {itemId: item.id},
        error: (xhr, status, error) ->
            console.log(error)
        success: (data, status, xhr) ->
            console.log(data)

            if item.unread
              currentGroup.unread -= 1
              consolidateGroup(currentGroup)

            item.unread = 0
            existing = $("div#items ul li[data-item-id=" + item.id + "]").removeClass("unread")

markAllRead = () ->
    $.ajax "/api/mark_all_read.json",
        type: "POST",
        dataType: "json",
        data: {groupId: currentGroup.id},
        success: (data, status, xhr) ->
            currentGroup.unread = 0
            consolidateGroup(currentGroup)
            item.unread = 0 for item in items
            $("div#items ul li").removeClass("unread")

shareToPocket = () ->
    if selectedItem != null
      $.ajax "/api/share.json",
      type: "POST",
      dataType: "json",
      data: {itemId: selectedItem.id, app: "pocket"},
      error: (xhr, status, error) ->
        console.log(error)
      success: (data, status, xhr) ->
        if data.success
          if selectedItem.unread
            currentGroup.unread -= 1
            consolidateGroup(currentGroup)
          selectedItem.unread = 0
          $("div#items ul li[data-item-id=" + selectedItem.id + "]").removeClass("unread")

groupsWithUnreadItems = () ->
    groups.filter (group) -> group.unread > 0

consolidateGroup = (group) ->
    existing = $("div#groups ul li[data-group-id=" + group.id + "]")

    li = document.createElement("li")
    $(li).attr("data-group-id", group.id)
    a = document.createElement("a")
    $(a).attr("href", "#")
    $(a).text(group.name + " (" + parseInt(group.unread,10) + ")")
    if currentGroup != null and group.id == currentGroup.id
      $(li).addClass("active")
      currentGroup = group
    $(li).append(a)

    $(a).click((event) ->
        console.log(group.name)
        selectGroup(group)
        event.preventDefault()
    )

    if existing.length > 0
      $(existing[0]).replaceWith(li)
    else
      # create a new group in the list
      $("div#groups ul").append(li)
    if parseInt(group.unread) > 0
      $(li).show()
    else
      if currentGroup != null && group.id == currentGroup.id
        $(li).show()
      else
        $(li).hide()

removeGroup = (group) ->
    $("div#groups ul li [data-group-id=" + group.id + "]").remove()

selectGroup = (group) ->
  console.log("selecting group: " + group.name)
  li = $("div#groups ul li[data-group-id=" + group.id + "]")
  if currentGroup != null && currentGroup.id != group.id
    oldGroup = currentGroup
  else
    oldGroup = null
  currentGroup = group
  if oldGroup != null
    consolidateGroup(oldGroup)
  $("div#items div#groupButtons").show()
  $("div#groups ul li").removeClass("active")
  $(li).addClass("active")
  window.quickfeed.loadItems(group.id)
  $("html, body").animate({
    scrollTop: 0
  }, 0)

consolidateItem = (item) ->
    existing = $("div#items ul li[data-item-id=" + item.id + "]")

    published = new Date(item.published_at)
    published_formatted = (published.getMonth()+1) + "/" + published.getDate() + "/" + published.getFullYear()

    li = document.createElement("li")
    $(li).attr("data-item-id", item.id)
    if item.unread
      $(li).addClass("unread")
    a = document.createElement("a")
    $(a).addClass("pull-left")
    $(a).attr("href", "#")
    $(a).html(item.title)
    $(li).append(a)
    date = document.createElement("span")
    $(date).addClass("pull-right")
    $(date).text(published_formatted)
    $(li).append(date)
    clear = document.createElement("div")
    $(clear).addClass("clearfix")
    $(li).append(clear)

    $(a).click((event) ->
        clickItem(item)
        event.preventDefault()
    )

    if existing.length > 0
      $(existing[0]).replaceWith(li)
    else
      $("div#items ul").append(li)

clickItem = (item) ->
  selectItem(item)

  if item == currentItem
    unexpandItem()
  else
    readItem(item)
    expandItem(item)

consolidateMoreButton = (numItems) ->
  if $("div#items > ul > li").length < numItems
    $("div#items > div#itemListButtons > a#moreItems").show()
  else
    $("div#items > div#itemListButtons > a#moreItems").hide()

unselectItem = () ->
    selectedItem = null
    $("div#items ul li").removeClass("focused")

selectItem = (item) ->
    unselectItem()
    selectedItem = item
    li = $("div#items ul li[data-item-id=" + item.id + "]")
    li.addClass("focused")

expandItem = (item) ->
  unexpandItem()

  li = $("div#items ul li[data-item-id=" + item.id + "]")

  currentItem = item
  console.log(item)

  title = document.createElement("a")
  $(title).addClass("title")
  $(title).attr("href", item.url)
  $(title).attr("target", "_blank")
  $(title).html(item.title)
  author = document.createElement("span")
  $(author).addClass("author")
  $(author).addClass("pull-left")
  $(author).text(item.author)
  feedTitle = document.createElement("span")
  $(feedTitle).addClass("feedTitle")
  $(feedTitle).addClass("pull-right")
  if item.feed_name != null
    $(feedTitle).text(item.feed_name)
  else
    $(feedTitle).text(item.feed_title)
  byline = document.createElement("div")
  if item.author != null
    $(byline).append(author)
  if item.feed_name != null || item.feed_title != null
    $(byline).append(feedTitle)
  bylineClear = document.createElement("div")
  $(bylineClear).addClass("clearfix")
  $(byline).append(bylineClear)
  summary = document.createElement("div")
  $(summary).addClass("summary")
  $(summary).html(item.summary)
  content = document.createElement("div")
  $(content).addClass("content")
  $(content).html(item.content)

  article = document.createElement("div")
  $(article).addClass("article")

  $(article).append(title)
  $(article).append(byline)
  if item.summary != null
    $(article).append(summary)
  if item.summary != null && item.content != null
    $(article).append(document.createElement("hr"))
  if item.content != null
    $(article).append(content)


  $(li).append(article)
  $(article).find("a").attr("target", "_blank")

  scrollToItem(item)

scrollToItem = (item) ->
  li = $("div#items ul li[data-item-id=" + item.id + "]")
  $("html, body").animate({
    scrollTop: $(li).offset().top - $("div.container.nav-collapse").height() - 2
  }, 0)

unexpandItem = () ->
  currentItem = null
  $("div#items ul li .article").remove()
  scrollToItem(selectedItem)

nextItem = () ->
    item = null
    if items != null && items.length > 0
      if selectedItem == null
        item = items[0]
      else
        currentIndex = items.indexOf(selectedItem)
        if currentIndex == -1
          item = items[0]
        else if currentIndex + 1 < items.length
          item = items[currentIndex + 1]
    return item

previousItem = () ->
    item = null
    if items != null && items.length > 0
      if selectedItem != null
        index = items.indexOf(selectedItem)
        if index > 0
          item = items[index - 1]
    return item

selectNext = () ->
    item = nextItem()
    if item != null
      selectItem(item)
      scrollToItem(item)

selectPrevious = () ->
    item = previousItem()
    if item != null
      selectItem(item)
      scrollToItem(item)

expandNext = () ->
    item = nextItem()
    if item != null
      clickItem(item)

expandPrevious = () ->
    item = previousItem()
    if item != null
      clickItem(item)

openCurrentItemInNewTab = () ->
    if selectedItem != null
      readItem(selectedItem)
      window.open(selectedItem.url, "_blank")

registerKeyboardShortcuts = () ->
    which = {
      78: "n",
      79: "o",
      80: "p",
      74: "j",
      75: "k",
      86: "v",
      65: "a",
      82: "r",
      77: "m",
    }
    $(document).keydown((event) ->
        #console.log(event.which)
        if !event.altKey && !event.metaKey
          if event.shiftKey
            switch which[event.which]
              when "a" then markAllRead()
              when "m" then loadMoreItems()
          else
            switch which[event.which]
              when "n"
                  selectNext()
              when "p"
                  selectPrevious()
              when "o"
                  if selectedItem != null
                    clickItem(selectedItem)
              when "j"
                  expandNext()
              when "k"
                  expandPrevious()
              when "v"
                  openCurrentItemInNewTab()
              when "r"
                  shareToPocket()
    )

fixGroupsHeight = () ->
  $("div#groups").height($(window).height() - $("div.container.nav-collapse").height() - 20);

$("div#items div#groupButtons a#goToGroup").click((event) ->
    if currentGroup != null
      window.location.href = "/group/show/" + currentGroup.id
    event.preventDefault()
)

$("div#items div#groupButtons a#markAllRead").click((event) ->
    if currentGroup != null
      markAllRead()
    event.preventDefault()
)

$("div#items > div#itemListButtons > a#moreItems").click((event) ->
    if currentGroup != null
      loadMoreItems()
    event.preventDefault()
)

# only load the groups when the page loads IF they're on the reader page
if ($("div#groups").length > 0)
  fixGroupsHeight()
  registerKeyboardShortcuts()
  window.quickfeed.loadGroups()
  setInterval(window.quickfeed.loadGroups, 60000)
  window.onresize = (event) ->
    fixGroupsHeight()
