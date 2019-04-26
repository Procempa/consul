App.PollsQuestionsAdmin =
  initialize: ->
    $("input#poll_question_allow_many_answers").on
      click: ->
        App.PollsQuestionsAdmin.updateTextFields($(this).prop('checked'));
    if ($("input#poll_question_allow_many_answers").size() > 0)
      App.PollsQuestionsAdmin.updateTextFields($("input#poll_question_allow_many_answers").prop('checked'));
  updateTextFields : (checkboxVal) -> 
    if checkboxVal
      $("input#poll_question_qtd_min_answers").removeProp("disabled");
      $("input#poll_question_qtd_max_answers").removeProp("disabled"); 
    else   
      $("input#poll_question_qtd_min_answers").val("");
      $("input#poll_question_qtd_max_answers").val("");
      $("input#poll_question_qtd_min_answers").prop("disabled", "disabled");
      $("input#poll_question_qtd_max_answers").prop("disabled", "disabled");
