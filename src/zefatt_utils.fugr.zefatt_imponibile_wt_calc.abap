FUNCTION zefatt_imponibile_wt_calc.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(I_QSSKZ) LIKE  BSEG-QSSKZ
*"     VALUE(I_LAND1) LIKE  T001-LAND1
*"     VALUE(WITHT) LIKE  T059Z-WITHT OPTIONAL
*"     VALUE(EXTENDED_WT) TYPE  FLAG OPTIONAL
*"  CHANGING
*"     VALUE(C_QSSHB) LIKE  BSEG-QSSHB
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  DATA: lv_qsshb TYPE bseg-qsshb.

  TABLES: t059q, t059z.

* Recupero la Quota di imponibile soggetta a rit. d'acconto

* Controllo se è attiva la gestione della ritenuta d'acconto apmliata
  IF extended_wt IS INITIAL.

    SELECT SINGLE * FROM  t059q
           WHERE land1 = i_land1
           AND   qsskz = i_qsskz.

    lv_qsshb =  c_qsshb * t059q-qsatz / t059q-qproz.

  ELSE.

    SELECT SINGLE * FROM  t059z
           WHERE land1     = i_land1
           AND   witht     = witht
           AND   wt_withcd = i_qsskz.

    lv_qsshb =  c_qsshb * t059z-qsatz / t059z-qproz.

  ENDIF.

  IF sy-subrc NE 0.
    RAISE not_found.
  ENDIF.

  c_qsshb = c_qsshb - lv_qsshb.

ENDFUNCTION.
