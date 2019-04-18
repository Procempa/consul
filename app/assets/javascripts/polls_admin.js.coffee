App.PollsAdmin =
  initialize: ->
    $("select[class='js-poll-shifts']").on
      change: ->
        switch ($(this).val())
          when 'vote_collection'
            $("select[class='js-shift-vote-collection-dates']").show();
            $("select[class='js-shift-recount-scrutiny-dates']").hide();
          when 'recount_scrutiny'
            $("select[class='js-shift-recount-scrutiny-dates']").show();
            $("select[class='js-shift-vote-collection-dates']").hide();
    $("input#poll_question_allow_many_answers").on
      click: ->
        App.PollsAdmin.updateTextFields($(this).prop("checked"))
    updateTextFields($(this).prop("checked"));
  updateTextFields: (checkboxVal) -> 
    if checkboxVal
      $("input#poll_question_qtd_min_answers").removeProp("disabled");
      $("input#poll_question_qtd_max_answers").removeProp("disabled"); 
    else          
      $("input#poll_question_qtd_min_answers").val("");
      $("input#poll_question_qtd_max_answers").val("");
      $("input#poll_question_qtd_min_answers").prop("disabled", "disabled");
      $("input#poll_question_qtd_max_answers").prop("disabled", "disabled");   
