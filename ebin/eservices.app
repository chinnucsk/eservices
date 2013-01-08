{application,eservices,
    [{description,"JSON Services for Defaceit writed on erlang"},
     {vsn,"0.0.1"},
     {modules,
         [eservices_incoming_mail_controller,
<<<<<<< HEAD
          eservices_outgoing_mail_controller,eservices_queue_controller,
          eservices_question_controller,squeue,stoplist,question,
          eservices_view_lib_tags,eservices_custom_filters,
=======
          eservices_outgoing_mail_controller,eservices_question_controller,
          eservices_queue_controller,eservices_variable_controller,question,
          squeue,stoplist,eservices_view_lib_tags,eservices_custom_filters,
>>>>>>> aa1369a4bd89f0bc010738f7c4dc82202abd29dc
          eservices_custom_tags]},
     {registered,[]},
     {applications,[kernel,stdlib,crypto,boss]},
     {env,
         [{test_modules,[]},
          {lib_modules,[]},
          {mail_modules,
              [eservices_incoming_mail_controller,
               eservices_outgoing_mail_controller]},
          {controller_modules,
<<<<<<< HEAD
              [eservices_queue_controller,eservices_question_controller]},
          {model_modules,[squeue,stoplist,question]},
=======
              [eservices_question_controller,eservices_queue_controller,
               eservices_variable_controller]},
          {model_modules,[question,squeue,stoplist]},
>>>>>>> aa1369a4bd89f0bc010738f7c4dc82202abd29dc
          {view_lib_tags_modules,[eservices_view_lib_tags]},
          {view_lib_helper_modules,
              [eservices_custom_filters,eservices_custom_tags]},
          {view_modules,[]}]}]}.
