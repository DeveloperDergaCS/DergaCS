FUNCTION zefatt_attachment.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  XSTRING
*"----------------------------------------------------------------------

  DATA: lv_base64_pdf TYPE string.

  MOVE input TO lv_base64_pdf.

  CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
    EXPORTING
      input  = lv_base64_pdf
    IMPORTING
      output = output
    EXCEPTIONS
      failed = 1
      OTHERS = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFUNCTION.
