FUNCTION zefatt_unita_misura.
*"--------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"--------------------------------------------------------------------

  TRANSLATE input TO UPPER CASE.

  IF input = 'NR'.

    output = 'ST'.

  ELSE.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = input
      IMPORTING
        output         = output
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      output = input.
    ENDIF.

  ENDIF.


ENDFUNCTION.
