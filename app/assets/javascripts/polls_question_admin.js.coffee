App.PollQuestionsAdmin =

  initialize: ->
    $("input#poll_question_allow_many_answers").on
      click: ->
        App.PollQuestionsAdmin.updateTextFields($(this).val())


   updateTextFields(checkboxVal): -> 
        switch (checkboxVal)
          when 'true'
            $("innput[id='poll_question_qtd_min_answers']").removeProp("disabled");
            $("innput[id='poll_question_qtd_max_answers']").removeProp("disabled"); 
          else          
            $("innput[id='poll_question_qtd_min_answers']").text("");
            $("innput[id='poll_question_qtd_max_answers']").text("");
            $("innput[id='poll_question_qtd_min_answers']").prop("disabled", "disabled");
            $("innput[id='poll_question_qtd_max_answers']").prop("disabled", "disabled"   