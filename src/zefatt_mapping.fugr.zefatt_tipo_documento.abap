FUNCTION zefatt_tipo_documento.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"     VALUE(SPLIT_PAYMENT) TYPE  ZEFATT_SPLIT_PAYMENT
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  SELECT SINGLE blart_acc FROM zefatt_reg_td INTO output
         WHERE itdpa         = input
         AND   split_payment = split_payment.

ENDFUNCTION.
