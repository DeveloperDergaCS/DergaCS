FUNCTION zefatt_call_transaction_miro.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(END_TASK) TYPE  FLAG
*"----------------------------------------------------------------------

  SET PARAMETER ID 'BUK' FIELD bukrs.

  CALL TRANSACTION 'MIRO' AND SKIP FIRST SCREEN.

  end_task = 'X'.

ENDFUNCTION.
