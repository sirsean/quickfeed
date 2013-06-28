$ ->
  $("form#subscribe").bind("ajax:success", (xhr, data, status) -> (
    window.location.href = "/subscribe/complete/" + data.feed_id
  ))

  $("form#complete_subscription select#feed_form_group_id").change(() ->
      value = $("form#complete_subscription select#feed_form_group_id").val()
      newGroupName = $("form#complete_subscription input#feed_form_group_name").parent().parent()
      if parseInt(value) == -1
        newGroupName.show()
      else
        newGroupName.hide()
  )
