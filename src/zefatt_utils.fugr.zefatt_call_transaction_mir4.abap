FUNCTION zefatt_call_transaction_mir4.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BELNR) TYPE  BELNR_D
*"     VALUE(GJAHR) TYPE  GJAHR
*"  EXPORTING
*"     VALUE(END_TASK) TYPE  FLAG
*"----------------------------------------------------------------------


  SET PARAMETER ID 'RBN' FIELD belnr.
  SET PARAMETER ID 'GJR' FIELD gjahr.

  CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.

  end_task = 'X'.

ENDFUNCTION.
