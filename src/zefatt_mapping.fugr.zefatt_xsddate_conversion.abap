FUNCTION zefatt_xsddate_conversion.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  DATA: lv_xml_string   TYPE string,
        lv_date_string  TYPE string,
        lv_xsd_date     TYPE xsddatetime_z,
        lv_timestamp    TYPE timestamp,
        lv_date         TYPE dats,
        lv_time         TYPE uzeit.

* Riporto la stringa data in un formato XML
  CALL TRANSFORMATION id
       SOURCE root = input
       RESULT XML lv_xml_string.

* Faccio la conversione da formato XML in formato XDS Date
  TRY .

      CALL TRANSFORMATION id
           SOURCE XML lv_xml_string
           RESULT root = lv_xsd_date.


* Converto il timestamp ottenuto in data e ora
      lv_timestamp = lv_xsd_date.
      CONVERT TIME STAMP lv_timestamp  TIME ZONE sy-zonlo
              INTO DATE lv_date TIME lv_time.

      output = lv_date.

    CATCH cx_sy_conversion_no_date_time.
    CATCH cx_xslt_abap_call_error.
    CATCH cx_xslt_deserialization_error .
    CATCH cx_xslt_format_error.
    CATCH cx_xslt_serialization_error.
    CATCH cx_st_error.

  ENDTRY.


ENDFUNCTION.
