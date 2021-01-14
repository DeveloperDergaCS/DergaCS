FUNCTION zefatt_cod_iva.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(ALIQUOTA) TYPE  ZEFATT_ALIQUOTA OPTIONAL
*"     VALUE(NATURA) TYPE  ZIT_NATURA OPTIONAL
*"     VALUE(ESIGIBILITA) TYPE  ZEFATT_ESIGIBILITA OPTIONAL
*"  EXPORTING
*"     VALUE(MWSKZ) TYPE  MWSKZ
*"----------------------------------------------------------------------

  SELECT SINGLE mwskz FROM zefatt_natur INTO mwskz
         WHERE bukrs       = bukrs
         AND   lifnr       = lifnr
         AND   natura      = natura
         AND   aliquota    = aliquota
         AND   esigibilita = esigibilita.

  IF sy-subrc <> 0.

    SELECT SINGLE mwskz FROM zefatt_natur INTO mwskz
           WHERE bukrs       = bukrs
           AND   lifnr       = space
           AND   natura      = natura
           AND   aliquota    = aliquota
           AND   esigibilita = esigibilita.

    IF sy-subrc <> 0.

      SELECT SINGLE mwskz FROM zefatt_natur INTO mwskz
             WHERE bukrs       = bukrs
             AND   lifnr       = space
             AND   natura      = natura
             AND   aliquota    = aliquota
             AND   esigibilita = space.

      IF sy-subrc <> 0.

        SELECT SINGLE mwskz FROM zefatt_natur INTO mwskz
               WHERE bukrs       = bukrs
               AND   lifnr       = space
               AND   natura      = space
               AND   aliquota    = aliquota
               AND   esigibilita = space.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFUNCTION.
