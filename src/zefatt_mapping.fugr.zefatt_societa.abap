FUNCTION zefatt_societa.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  SELECT SINGLE bukrs FROM t001 INTO output
         WHERE stceg = input.

ENDFUNCTION.
