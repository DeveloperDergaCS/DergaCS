FUNCTION zefatt_call_transaction_fb03.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(BELNR) TYPE  BELNR_D
*"     VALUE(GJAHR) TYPE  GJAHR
*"  EXPORTING
*"     VALUE(END_TASK) TYPE  FLAG
*"----------------------------------------------------------------------

  SET PARAMETER ID 'BLN' FIELD belnr.
  SET PARAMETER ID 'BUK' FIELD bukrs.
  SET PARAMETER ID 'GJR' FIELD gjahr.

  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

  end_task = 'X'.

ENDFUNCTION.
