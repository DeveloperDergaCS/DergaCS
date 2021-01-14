FUNCTION zefatt_conversion_output.
*"--------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"--------------------------------------------------------------------

  SHIFT input LEFT DELETING LEADING '0'.

  output = input.

ENDFUNCTION.
