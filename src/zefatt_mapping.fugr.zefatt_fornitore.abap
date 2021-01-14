FUNCTION zefatt_fornitore.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  TABLES lfa1.

  CLEAR output.
  CLEAR lfa1.

  SELECT lifnr INTO lfa1-lifnr
         FROM lfa1
         WHERE stceg = input
         AND   loevm = space.

    SELECT SINGLE lifnr INTO output
         FROM lfb1
         WHERE lifnr = lfa1-lifnr
         AND   bukrs = bukrs
         AND   loevm = space.

    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.

  ENDSELECT.

  IF output IS INITIAL.

    CLEAR lfa1.
    SELECT lifnr INTO lfa1-lifnr
           FROM lfa1
           WHERE land1 = input(2)
           AND   stcd2 = input+2
           AND   loevm = space.

      SELECT SINGLE lifnr INTO output
           FROM lfb1
           WHERE lifnr = lfa1-lifnr
           AND   bukrs = bukrs
           AND   loevm = space.

      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.

    ENDSELECT.

  ENDIF.

ENDFUNCTION.
