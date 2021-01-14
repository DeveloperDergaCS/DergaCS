FUNCTION zefatt_date_conversion.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  REPLACE ALL OCCURRENCES OF '-' IN input WITH ' '.
  REPLACE ALL OCCURRENCES OF '.' IN input WITH ' '.
  REPLACE ALL OCCURRENCES OF '/' IN input WITH ' '.
  CONDENSE input NO-GAPS.

  output = input.

ENDFUNCTION.
