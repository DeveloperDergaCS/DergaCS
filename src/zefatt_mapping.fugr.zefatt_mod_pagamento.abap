FUNCTION zefatt_mod_pagamento.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  SELECT SINGLE zlsch FROM zefatt_modpaga INTO output
         WHERE modpag = input.

ENDFUNCTION.
