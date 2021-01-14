interface ZIF_FATT_BADI_API
  public .


  interfaces IF_BADI_INTERFACE .

  methods HANDLE_REQUEST_CONNECT
    importing
      value(IV_BUKRS) type BUKRS
      value(IO_HTTP_REQUEST) type ref to IF_HTTP_REQUEST optional
      value(SOAP_CONNECT) type ref to OBJECT optional
      value(USER) type ZFATT_USER
      value(PASSWORD) type ZFATT_PSW
    exporting
      value(EV_REQUEST) type XSTRING .
  methods HANDLE_RESPONSE_CONNECT
    importing
      value(IO_HTTP_RESPONSE) type ref to IF_HTTP_RESPONSE
    exporting
      value(RETURN) type BAPIRET2 .
  methods HANDLE_REQUEST_SEND_INVOICE
    importing
      value(IV_BUKRS) type BUKRS
      value(IV_XML) type ZEFATT_FILE
      value(IV_FILENAME) type ZEFATT_FILE_NAME
      value(IO_HTTP_REQUEST) type ref to IF_HTTP_REQUEST optional
      value(SOAP_CONNECT) type ref to OBJECT optional
      value(API_RESTULL_CONNECT) type ref to IF_HTTP_CLIENT
    exporting
      value(EV_REQUEST) type XSTRING .
  methods HANDLE_RESPONSE_SEND_INVOICE
    importing
      value(IO_HTTP_RESPONSE) type ref to IF_HTTP_RESPONSE
    exporting
      value(RETURN) type BAPIRET2 .
  methods HANDLE_REQUEST_INCOMING_INV
    importing
      value(IV_BUKRS) type BUKRS
      value(IO_HTTP_REQUEST) type ref to IF_HTTP_REQUEST optional
      value(SOAP_CONNECT) type ref to OBJECT optional
      value(API_RESTULL_CONNECT) type ref to IF_HTTP_CLIENT
    exporting
      value(EV_REQUEST) type XSTRING .
  methods HANDLE_RESPONSE_INCOMING_INV
    importing
      value(IO_HTTP_RESPONSE) type ref to IF_HTTP_RESPONSE
    exporting
      value(RETURN) type BAPIRET2
      value(XML) type ZEFATT_FILE
      value(FILENAME) type ZEFATT_FILE_NAME
      value(SDI_DATE) type ZEFATT_SDI_DATE .
  methods HANDLE_REQUEST_INCOMING_NOTIF
    importing
      value(IV_BUKRS) type BUKRS
      value(IO_HTTP_REQUEST) type ref to IF_HTTP_REQUEST optional
      value(SOAP_CONNECT) type ref to OBJECT optional
      value(API_RESTULL_CONNECT) type ref to IF_HTTP_CLIENT
    exporting
      value(EV_REQUEST) type XSTRING .
  methods HANDLE_RESPONSE_INCOMING_NOTIF
    importing
      value(IO_HTTP_RESPONSE) type ref to IF_HTTP_RESPONSE
    exporting
      value(RETURN) type BAPIRET2
      value(XML) type ZEFATT_FILE .
endinterface.
