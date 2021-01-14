FUNCTION zefatt_call_transaction_fb01.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(MODE) LIKE  APQI-PUTACTIVE DEFAULT 'E'
*"     VALUE(UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(NODATA) LIKE  APQI-PUTACTIVE DEFAULT '/'
*"     VALUE(BLDAT) LIKE  BKPF-BLDAT
*"     VALUE(BLART) LIKE  BKPF-BLART
*"     VALUE(BUKRS) LIKE  BKPF-BUKRS
*"     VALUE(BUDAT) LIKE  BKPF-BUDAT
*"     VALUE(WAERS) LIKE  BKPF-WAERS
*"     VALUE(XBLNR) LIKE  BKPF-XBLNR
*"     VALUE(VATDATE) LIKE  BKPF-VATDATE
*"  EXPORTING
*"     VALUE(END_TASK) TYPE  FLAG
*"----------------------------------------------------------------------

  DATA: subrc	      TYPE syst-subrc,
        messtab     TYPE STANDARD TABLE OF bdcmsgcoll,
        bldat_bdc   TYPE bdcdata-fval,
        budat_bdc   TYPE bdcdata-fval,
        vatdate_bdc TYPE bdcdata-fval.

  subrc = 0.

  WRITE: bldat   TO bldat_bdc,
         budat   TO budat_bdc,
         vatdate TO vatdate_bdc.

  PERFORM bdc_nodata      USING nodata.

  PERFORM open_group      USING group user keep holddate ctu.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BKPF-VATDATE'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                bldat_bdc.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                blart.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                bukrs.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                budat_bdc.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                waers.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                xblnr.
  PERFORM bdc_field       USING 'BKPF-VATDATE'
                                vatdate_bdc.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/ECNC'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWBS'.
  PERFORM bdc_dynpro      USING 'SAPLSPO1' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=YES'.
  PERFORM bdc_transaction TABLES messtab
  USING                         'FB01'
                                ctu
                                mode
                                update.
  IF sy-subrc <> 0.
    subrc = sy-subrc.
    EXIT.
  ENDIF.

  PERFORM close_group USING     ctu.

  end_task = 'X'.

ENDFUNCTION.

INCLUDE bdcrecxy.
