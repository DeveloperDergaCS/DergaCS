FUNCTION zefatt_oda.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  DATA: lenght TYPE i,
        ebeln  TYPE ebeln.

  lenght = STRLEN( input ).

* Controllo se posso fare la conversione del numero dell'ordine
* d'acquisto in quanto possiamo avere numeri più lunghi di 10
  IF lenght <= 10.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = input
      IMPORTING
        output = ebeln.

    output = ebeln.

  ELSE.

    output = input.

  ENDIF.

ENDFUNCTION.
