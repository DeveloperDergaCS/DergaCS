FUNCTION zefatt_call_transaction_fbv0.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(BELNR) TYPE  BELNR_D
*"     VALUE(GJAHR) TYPE  GJAHR
*"  EXPORTING
*"     VALUE(END_TASK) TYPE  FLAG
*"----------------------------------------------------------------------

  DATA: rfopt2 TYPE rfopt2.

* Setto il parametro per impostare il calcolo delle imposte al netto
  GET PARAMETER ID 'FO2' FIELD rfopt2.

  rfopt2-xsnet = 'X'.

  SET PARAMETER ID 'FO2' FIELD rfopt2.

  SET PARAMETER ID 'BLP' FIELD belnr.
  SET PARAMETER ID 'BUK' FIELD bukrs.
  SET PARAMETER ID 'GJR' FIELD gjahr.

  CALL TRANSACTION 'FBV0' AND SKIP FIRST SCREEN.

* Resetto il parametro per impostare il calcolo delle imposte al netto
  GET PARAMETER ID 'FO2' FIELD rfopt2.

  rfopt2-xsnet = ' '.

  SET PARAMETER ID 'FO2' FIELD rfopt2.

  end_task = 'X'.

ENDFUNCTION.
