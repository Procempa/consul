App.Polls =
  generateToken: ->
    token = ''
    rand = ''
    for n in [0..5]
      rand = Math.random().toString(36).substr(2) # remove `0.`
      token = token + rand;

    token = token.substring(0, 64)
    return token

  replaceToken: ->
    for link in $('.js-question-answer')
      if link && link.length > 0
        token_param = link.search.slice(-6)
        if token_param == "token="
          link.href = link.href + @token
    if $("input[name='token']").size() > 0
      $("input[name='token']").val(@token);          

  initialize: ->
    @token = App.Polls.generateToken()
    App.Polls.replaceToken()
    #App.Polls.updateMaxAndMinimum()

    if $("input[name='token']").size() > 0
      $("input[name='token']").val(@token);          

    $("input[name^='answer_question_'][type='checkbox']").on
      click: ->
        App.Polls.updateMaxAndMinimum()

    $(".polls-show label.button").on "click", () ->
      if !$(this).hasClass('answered')
        $(this).attr('class', 'button secondary hollow js-question-answer')
      $(this).siblings("label.button").attr("class", "button secondary hollow js-question-answer")

    $(".polls-show .js-question-answer").on
      click: =>
        token_message = $(".js-token-message")
        if !token_message.is(':visible')
          token_message.html(token_message.html() + "<br><strong>" + @token + "</strong>");
          token_message.show()
    false

    $(".zoom-link").on "click", (event) ->
      element = event.target
      answer = $(element).closest('div.answer')

      if $(answer).hasClass('medium-6')
        $(answer).removeClass("medium-6");
        $(answer).addClass("answer-divider");
        unless $(answer).hasClass('first')
          $(answer).insertBefore($(answer).prev('div.answer'));
      else
        $(answer).addClass("medium-6");
        $(answer).removeClass("answer-divider");
        unless $(answer).hasClass('first')
          $(answer).insertAfter($(answer).next('div.answer'));
  
  updateMaxAndMinimum: ->
    $("input[name^='question_limit_max_']").each ->
      questionId = $(this).attr("id").split("question_limit_max_")[1]
      maxValue = parseInt($(this).val())
      if maxValue && maxValue == $("input[name='answer_question_" + questionId + "[]']").filter(':checked').size()
        $("input[name='answer_question_" + questionId + "[]']").each ->
          if !$(this).prop('checked')
            $(this).prop('disabled', 'disabled')
      else
        $("input[name='answer_question_" + questionId + "[]']").each ->
          $(this).removeProp('disabled')