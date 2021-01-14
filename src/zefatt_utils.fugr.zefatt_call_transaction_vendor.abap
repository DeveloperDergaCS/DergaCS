FUNCTION zefatt_call_transaction_vendor.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(LIFNR) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(END_TASK) TYPE  FLAG
*"----------------------------------------------------------------------

  DATA: ls_cvers   TYPE cvers,
        lo_request TYPE REF TO cl_bupa_navigation_request,
        lo_options TYPE REF TO cl_bupa_dialog_joel_options.

* Controllo se sono su sistema S/4HANA
  SELECT COUNT(*) FROM cvers INTO ls_cvers
         WHERE component EQ 'S4CORE'.

  IF sy-subrc <> 0.

* Se non si tratta di sistema S/4HANA vuol dire che devo visualizzare il fornitore con trx FK03
    SET PARAMETER ID 'LIF' FIELD lifnr.
    SET PARAMETER ID 'BUK' FIELD bukrs.
    SET PARAMETER ID 'KDY' FIELD '/111/120/130/380/210/215/220/610'.

    CALL TRANSACTION 'FK03' AND SKIP FIRST SCREEN.

  ELSE.

* Se si tratta di sistema S/4HANA vuol dire che devo visualizzare il fornitore con trx BP
    CREATE OBJECT lo_request.

    CALL METHOD lo_request->set_partner_number( lifnr ).

    CALL METHOD lo_request->set_maintenance_id
      EXPORTING
        iv_value = lo_request->gc_maintenance_id_partner.

    CALL METHOD lo_request->set_bupa_activity
      EXPORTING
        iv_value = lo_request->gc_activity_display.

    CREATE OBJECT lo_options.
    CALL METHOD lo_options->set_locator_visible( space ).

    CALL METHOD cl_bupa_dialog_joel=>start_with_navigation
      EXPORTING
        iv_request              = lo_request
        iv_options              = lo_options
        iv_in_new_internal_mode = ' '
        iv_in_new_window        = ' '
      EXCEPTIONS
        already_started         = 1
        not_allowed             = 2
        OTHERS                  = 3.

  ENDIF.

  end_task = 'X'.

ENDFUNCTION.
