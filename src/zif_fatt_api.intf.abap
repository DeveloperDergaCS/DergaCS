interface ZIF_FATT_API
  public .


  data API_RESTULL_CONNECT type ref to IF_HTTP_CLIENT .
  data SOAP_CONNECT type ref to OBJECT .
  data BADI_FATT_API type ref to ZFATT_BADI_API .
  data API_RESTULL_SEND_INVOICE type ref to IF_HTTP_CLIENT .
  data API_RESTULL_INCOMING_INVOICE type ref to IF_HTTP_CLIENT .
  data API_RESTULL_INCOMING_NOTIF type ref to IF_HTTP_CLIENT .

  methods CONNECT_TO_SERVICE
    importing
      value(BUKRS) type BUKRS
      value(INTERFACCIA) type ZEFATT_INTERFACCIA
    exporting
      value(RETURN) type BAPIRET2 .
  methods SEND_INVOICE
    importing
      value(BUKRS) type BUKRS
      value(INTERFACCIA) type ZEFATT_INTERFACCIA
      value(XML) type ZEFATT_FILE
      value(FILENAME) type ZEFATT_FILE_NAME
    exporting
      value(RETURN) type BAPIRET2 .
  methods INCOMING_INVOICE
    importing
      value(BUKRS) type BUKRS
      value(INTERFACCIA) type ZEFATT_INTERFACCIA
    exporting
      value(XML) type ZEFATT_FILE
      value(FILENAME) type ZEFATT_FILE_NAME
      value(SDI_DATE) type ZEFATT_SDI_DATE
      value(RETURN) type BAPIRET2 .
  methods INCOMING_NOTIFICATION
    importing
      value(BUKRS) type BUKRS
      value(INTERFACCIA) type ZEFATT_INTERFACCIA
    exporting
      value(XML) type ZEFATT_FILE
      value(RETURN) type BAPIRET2 .
  methods CLOSE
    exporting
      value(RETURN) type BAPIRET2 .
endinterface.
