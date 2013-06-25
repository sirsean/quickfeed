window.Reader = angular.module("reader", [])

Reader.factory("Bus", ($rootScope) ->
  bus = {}
  bus.broadcast = (name, obj) ->
    this.name = name
    this.obj = obj
    this.broadcastItem()
  bus.broadcastItem = ->
    $rootScope.$broadcast(this.name)
  return bus
)

Reader.controller("GroupsCtrl", ($scope, $http, Bus) ->
  $scope.version = null
  $scope.current = null

  groups = ->
    $http.get("/api/groups.json").success (response) ->
      if $scope.version != null and $scope.version != response.version
        $("#version-mismatch").show()
      $scope.version = response.version
      $scope.groups = response.groups
      nonEmpty = response.groups.filter (group) -> group.unread > 0
      if $scope.current == null
        if nonEmpty.length > 0
          $scope.current = nonEmpty[0]
        else
          $scope.current = null
      else
        $scope.current = ($scope.groups.filter (group) -> group.id == $scope.current.id)[0]

  $scope.chooseGroup = (group) ->
    if group.id == $scope.current.id
      Bus.broadcast("reloadGroup", group)
    $scope.current = group
    $("html, body").animate({
      scrollTop: 0
    }, 0)

  $scope.$watch("current.id", () ->
    Bus.broadcast("chooseGroup", $scope.current)
  )

  $scope.$on "key", ->
    switch Bus.obj
      when "A"
        markAllRead()

  $scope.$on "decrementGroupUnread", ->
    if Bus.obj
      $scope.current.unread--

  $scope.$on "markGroupRead", ->
    markAllRead()

  markAllRead = () ->
    $http({method: "POST", url: "/api/mark_all_read.json", data: {groupId: $scope.current.id}})
      .success (response) ->
        group.unread = 0 for group in $scope.groups.filter (group) -> group.id == response.group_id
        Bus.broadcast("markAllArticlesRead", response.group_id)

  fixGroupsHeight = () ->
    $("groups").height($(window).height() - $("div.container.nav-collapse").height() - 20)

  fixGroupsHeight()
  groups()
  window.onresize = (e) ->
    fixGroupsHeight()
  setInterval ->
    groups()
  , 30000
)

Reader.controller "ArticlesCtrl", ($scope, $http, Bus) ->
  $scope.current = null
  $scope.focused = null

  articles = (groupId, clear=false, lastId=0) ->
    if lastId == 0 or clear
      $scope.current = null
      $scope.focused = null
    if groupId != $scope.groupId or clear
      $scope.state = "loading"
      $scope.articles = []
    $scope.groupId = groupId
    $http({method: "GET", url: "/api/items.json", params: {groupId: groupId, lastItemId: lastId}})
      .success (response) ->
        $scope.numArticles = response.num_items
        $scope.articles = $scope.articles.concat(response.items)
        if response.num_items == 0
          $scope.state = "empty"
        else
          $scope.state = null
        $("#bottomButtons").hide()
      .error () ->
        $scope.state = "error"

  $scope.loadMoreArticles = ->
    if $scope.articles.length > 0
      last = $scope.articles[$scope.articles.length-1]
      articles($scope.groupId, false, last.id)

  $scope.$on "reloadGroup", () ->
    if Bus.obj
      articles(Bus.obj.id, true)
    else
      $scope.state = "none"

  $scope.$on "chooseGroup", () ->
    if Bus.obj
      articles(Bus.obj.id)
    else
      $scope.state = "none"

  markAsRead = (article) ->
    $http({method: "POST", url: "/api/read_item.json", data: {itemId: article.id}})
      .success (response) ->
        Bus.broadcast("decrementGroupUnread", article.unread)
        a.unread = 0 for a in $scope.articles.filter (a) -> a.id == response.item_id

  shareToPocket = (article) ->
    $http({method: "POST", url: "/api/share.json", data: {itemId: article.id, app: "pocket"}})
      .success (response) ->
        if response.success
          Bus.broadcast("decrementGroupUnread", article.unread)
          article.unread = 0

  $scope.$watch "focused", () ->
    scrollTo($scope.focused)

  $scope.$watch "current", () ->
    if $scope.current != null
      $(".article .full").hide()
      $(".article[data-article-id=" + $scope.current.id + "] .content").html($scope.current.content)
      $(".article[data-article-id=" + $scope.current.id + "]").find("a").attr("target", "_blank")
      $(".article[data-article-id=" + $scope.current.id + "] .full").show()
      scrollTo($scope.current)
      markAsRead($scope.current)

  $scope.$on "markAllArticlesRead", () ->
    article.unread = 0 for article in $scope.articles

  $scope.markAllRead = ->
    Bus.broadcast("markGroupRead")

  $scope.goToCurrentGroup = ->
    if $scope.groupId != null
      window.location.href = "/group/show/" + $scope.groupId
    

  $scope.$on "key", () ->
    switch Bus.obj
      when "n"
        article = nextArticle()
        if article != null
          $scope.focused = article
      when "p"
        article = previousArticle()
        if article != null
          $scope.focused = article
      when "j"
        article = nextArticle()
        if article != null
          $scope.focused = article
          $scope.current = article
      when "k"
        article = previousArticle()
        if article != null
          $scope.focused = article
          $scope.current = article
      when "o"
        scrollTo($scope.focused)
        if $scope.current != null and $scope.current == $scope.focused
          $scope.current = null
        else if $scope.focused != null
          $scope.current = $scope.focused
      when "v"
        if $scope.focused != null
          markAsRead($scope.focused)
          window.open($scope.focused.url, "_blank")
      when "r"
        shareToPocket($scope.focused)
      when "M"
        $scope.loadMoreArticles()

  $scope.chooseArticle = (article) ->
    if article != $scope.current
      $scope.focused = article
      $scope.current = article
    else
      $scope.current = null
    
  nextArticle = ->
    next = null
    if $scope.articles != null and $scope.articles.length > 0
      if $scope.focused == null
        next = $scope.articles[0]
      else
        index = $scope.articles.indexOf($scope.focused)
        if index == -1
          next = $scope.articles[0]
        else if index + 1 < $scope.articles.length
          next = $scope.articles[index + 1]
    return next

  previousArticle = ->
    prev = null
    if $scope.articles != null and $scope.articles.length > 0
      if $scope.focused != null
        index = $scope.articles.indexOf($scope.focused)
        if index > 0
          prev = $scope.articles[index - 1]
    return prev

  scrollTo = (article) ->
    if article != null
      element = $(".article[data-article-id=" + article.id + "]")
      $("html, body").animate({
        scrollTop: $(element).offset().top - $("div.container.nav-collapse").height() - 2
      }, 0)

Reader.controller("KeyCtrl", ($scope, $document, Bus) ->
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
  $document.keydown (e) ->
    $scope.$apply ->
      if !event.altKey && !event.metaKey
        if event.shiftKey
          if which[event.which]
            Bus.broadcast("key", which[event.which].toUpperCase())
        else
          if which[event.which]
            Bus.broadcast("key", which[event.which])
)

Reader.directive "groups", () ->
  restrict: "E",
  transclude: true,
  scope: {},
  controller: "GroupsCtrl",
  templateUrl: "assets/groups.html"

Reader.directive "articles", () ->
  restrict: "E",
  transclude: true,
  scope: {},
  controller: "ArticlesCtrl",
  templateUrl: "assets/articles.html"
