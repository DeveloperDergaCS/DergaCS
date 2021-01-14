class ZCL_FATT_REST_API definition
  public
  final
  create public .

public section.

  interfaces ZIF_FATT_API .

  methods CALL_API
    importing
      value(IV_REQUEST) type XSTRING
    changing
      value(IO_HTTP_CLIENT) type ref to IF_HTTP_CLIENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FATT_REST_API IMPLEMENTATION.


  METHOD call_api.

* Passo i dati alla API nel Body della richiesta
    io_http_client->request->set_data( iv_request ).

* Disabilitazione popup logon
    io_http_client->propertytype_logon_popup = if_http_client=>co_disabled.

* Invio la richiesta all'API
    io_http_client->send( EXCEPTIONS http_communication_failure = 1
                                     http_invalid_state         = 2 ).

* Ricezione della risposta
    io_http_client->receive( EXCEPTIONS http_communication_failure = 1
                                        http_invalid_state         = 2
                                        http_processing_failed     = 3 ).

  ENDMETHOD.


  METHOD zif_fatt_api~close.


    IF zif_fatt_api~api_restull_connect IS BOUND.

      zif_fatt_api~api_restull_connect->close( ).
      FREE zif_fatt_api~api_restull_connect.

    ENDIF.

    IF zif_fatt_api~api_restull_send_invoice IS BOUND.

      zif_fatt_api~api_restull_send_invoice->close( ).
      FREE zif_fatt_api~api_restull_send_invoice.

    ENDIF.

    IF zif_fatt_api~api_restull_incoming_invoice IS BOUND.

      zif_fatt_api~api_restull_incoming_invoice->close( ).
      FREE zif_fatt_api~api_restull_incoming_invoice.

    ENDIF.

    IF zif_fatt_api~api_restull_incoming_notif IS BOUND.

      zif_fatt_api~api_restull_incoming_notif->close( ).
      FREE zif_fatt_api~api_restull_incoming_notif.

    ENDIF.

  ENDMETHOD.


  METHOD zif_fatt_api~connect_to_service.

    DATA: rfc_login  TYPE zefatt_rfc_login,
          utente     TYPE zfatt_user,
          password   TYPE zfatt_psw,
          ev_request TYPE xstring.

* Recupero RFC di connessione al sistema del partner
    SELECT SINGLE rfc_login utente password FROM zefatt_conf_rest INTO (rfc_login, utente, password)
           WHERE interfaccia = interfaccia.

    CHECK rfc_login IS NOT INITIAL.

* Instanza della classe HTTP per il tramite della RFC
    cl_http_client=>create_by_destination( EXPORTING  destination              = rfc_login
                                           IMPORTING  client                   = zif_fatt_api~api_restull_connect
                                           EXCEPTIONS argument_not_found       = 1
                                                      destination_not_found    = 2
                                                      destination_no_authority = 3
                                                      plugin_not_active        = 4
                                                      internal_error           = 5
                                                      OTHERS                   = 6 ).

* Gestione della richiesta all'API tramite BaDi
    TRY.

        GET BADI zif_fatt_api~badi_fatt_api.

        IF zif_fatt_api~badi_fatt_api IS BOUND.

          CALL BADI zif_fatt_api~badi_fatt_api->handle_request_connect
            EXPORTING
              iv_bukrs        = bukrs
              io_http_request = zif_fatt_api~api_restull_connect->request
              user            = utente
              password        = password
            IMPORTING
              ev_request      = ev_request.

        ENDIF.

      CATCH cx_badi_not_implemented.

        return-type       = 'E'.
        return-id         = 'ZEFATTURA'.
        return-number     = '062'.
        return-message_v1 = 'ZFATT_BADI_API'.

        RETURN.

    ENDTRY.

    IF ev_request IS INITIAL.

      return-type        = 'E'.
      return-id          = 'ZEFATTURA'.
      return-number      = '061'.
      return-message_v1  = 'ZFATT_BADI_API'.
      return-message_v2  = 'HANDLE_REQUEST_CONNECT'.

      RETURN.

    ENDIF.

* Chiamata API
    call_api( EXPORTING iv_request      = ev_request
              CHANGING  io_http_client  = zif_fatt_api~api_restull_connect ).

* Gestione della risposta dell'API tramite BaDi
    IF zif_fatt_api~badi_fatt_api IS BOUND.

      CALL BADI zif_fatt_api~badi_fatt_api->handle_response_connect
        EXPORTING
          io_http_response = zif_fatt_api~api_restull_connect->response
        IMPORTING
          return           = return.

    ENDIF.

  ENDMETHOD.


  METHOD zif_fatt_api~incoming_invoice.

    DATA: rfc_service	TYPE zfatt_rfc_service,
          ev_request  TYPE xstring.

* Recupero RFC del servizio messo a disposizione dal partner
    SELECT SINGLE rfc_service FROM zefatt_conf_rest INTO rfc_service
           WHERE interfaccia = interfaccia
           AND   active      = 'X'.

    IF rfc_service IS INITIAL.

      return-type       = 'E'.
      return-id         = 'ZEFATTURA'.
      return-number     = '057'.

      RETURN.

    ENDIF.

* Instanza della classe HTTP per il tramite della RFC
    cl_http_client=>create_by_destination( EXPORTING  destination              = rfc_service
                                           IMPORTING  client                   = zif_fatt_api~api_restull_incoming_invoice
                                           EXCEPTIONS argument_not_found       = 1
                                                      destination_not_found    = 2
                                                      destination_no_authority = 3
                                                      plugin_not_active        = 4
                                                      internal_error           = 5
                                                      OTHERS                   = 6 ).

* Gestione della richiesta all'API tramite BaDi
    TRY.

        GET BADI zif_fatt_api~badi_fatt_api.

        IF zif_fatt_api~badi_fatt_api IS BOUND.

          CALL BADI zif_fatt_api~badi_fatt_api->handle_request_incoming_inv
            EXPORTING
              iv_bukrs            = bukrs
              io_http_request     = zif_fatt_api~api_restull_incoming_invoice->request
              api_restull_connect = zif_fatt_api~api_restull_connect
            IMPORTING
              ev_request          = ev_request.

        ENDIF.

      CATCH cx_badi_not_implemented.

        return-type       = 'E'.
        return-id         = 'ZEFATTURA'.
        return-number     = '062'.
        return-message_v1 = 'ZFATT_BADI_API'.

        RETURN.

    ENDTRY.

    IF ev_request IS INITIAL.

      return-type        = 'E'.
      return-id          = 'ZEFATTURA'.
      return-number      = '061'.
      return-message_v1  = 'ZFATT_BADI_API'.
      return-message_v2  = 'HANDLE_REQUEST_INCOMING_INV'.

      RETURN.

    ENDIF.

    call_api( EXPORTING iv_request      = ev_request
              CHANGING  io_http_client  = zif_fatt_api~api_restull_incoming_invoice ).

* Gestione della risposta dell'API tramite BaDi
    IF zif_fatt_api~badi_fatt_api IS BOUND.

      CALL BADI zif_fatt_api~badi_fatt_api->handle_response_incoming_inv
        EXPORTING
          io_http_response = zif_fatt_api~api_restull_incoming_invoice->response
        IMPORTING
          return           = return.

    ENDIF.

  ENDMETHOD.


  METHOD zif_fatt_api~incoming_notification.

    DATA: rfc_service TYPE zfatt_rfc_service,
          ev_request  TYPE xstring.

* Recupero RFC del servizio messo a disposizione dal partner
    SELECT SINGLE rfc_service FROM zefatt_conf_rest INTO rfc_service
           WHERE interfaccia = interfaccia
           AND   active      = 'X'.

    IF rfc_service IS INITIAL.

      return-type       = 'E'.
      return-id         = 'ZEFATTURA'.
      return-number     = '057'.

      RETURN.

    ENDIF.

* Instanza della classe HTTP per il tramite della RFC
    cl_http_client=>create_by_destination( EXPORTING  destination              = rfc_service
                                           IMPORTING  client                   = zif_fatt_api~api_restull_incoming_notif
                                           EXCEPTIONS argument_not_found       = 1
                                                      destination_not_found    = 2
                                                      destination_no_authority = 3
                                                      plugin_not_active        = 4
                                                      internal_error           = 5
                                                      OTHERS                   = 6 ).

* Gestione della richiesta all'API tramite BaDi
    TRY.

        GET BADI zif_fatt_api~badi_fatt_api.

        IF zif_fatt_api~badi_fatt_api IS BOUND.

          CALL BADI zif_fatt_api~badi_fatt_api->handle_request_incoming_notif
            EXPORTING
              iv_bukrs            = bukrs
              io_http_request     = zif_fatt_api~api_restull_incoming_notif->request
              api_restull_connect = zif_fatt_api~api_restull_connect
            IMPORTING
              ev_request          = ev_request.

        ENDIF.

      CATCH cx_badi_not_implemented.

        return-type       = 'E'.
        return-id         = 'ZEFATTURA'.
        return-number     = '062'.
        return-message_v1 = 'ZFATT_BADI_API'.

        RETURN.

    ENDTRY.

    IF ev_request IS INITIAL.

      return-type        = 'E'.
      return-id          = 'ZEFATTURA'.
      return-number      = '061'.
      return-message_v1  = 'ZFATT_BADI_API'.
      return-message_v2  = 'HANDLE_REQUEST_INCOMING_NOTIF'.

      RETURN.

    ENDIF.

    call_api( EXPORTING iv_request      = ev_request
              CHANGING  io_http_client  = zif_fatt_api~api_restull_incoming_notif ).

* Gestione della risposta dell'API tramite BaDi
    IF zif_fatt_api~badi_fatt_api IS BOUND.

      CALL BADI zif_fatt_api~badi_fatt_api->handle_response_incoming_notif
        EXPORTING
          io_http_response = zif_fatt_api~api_restull_incoming_notif->response
        IMPORTING
          return           = return.

    ENDIF.

  ENDMETHOD.


  METHOD zif_fatt_api~send_invoice.

    DATA: rfc_service	TYPE zfatt_rfc_service,
          ev_request  TYPE xstring.

* Recupero RFC del servizio messo a disposizione dal partner
    SELECT SINGLE rfc_service FROM zefatt_conf_rest INTO rfc_service
           WHERE interfaccia = interfaccia
           AND   active      = 'X'.

    IF rfc_service IS INITIAL.

      return-type       = 'E'.
      return-id         = 'ZEFATTURA'.
      return-number     = '057'.

      RETURN.

    ENDIF.

* Instanza della classe HTTP per il tramite della RFC
    cl_http_client=>create_by_destination( EXPORTING  destination              = rfc_service
                                           IMPORTING  client                   = zif_fatt_api~api_restull_send_invoice
                                           EXCEPTIONS argument_not_found       = 1
                                                      destination_not_found    = 2
                                                      destination_no_authority = 3
                                                      plugin_not_active        = 4
                                                      internal_error           = 5
                                                      OTHERS                   = 6 ).

* Gestione della richiesta all'API tramite BaDi
    TRY.

        GET BADI zif_fatt_api~badi_fatt_api.

        IF zif_fatt_api~badi_fatt_api IS BOUND.

          CALL BADI zif_fatt_api~badi_fatt_api->handle_request_send_invoice
            EXPORTING
              iv_bukrs            = bukrs
              iv_xml              = xml
              iv_filename         = filename
              io_http_request     = zif_fatt_api~api_restull_send_invoice->request
              api_restull_connect = zif_fatt_api~api_restull_connect
            IMPORTING
              ev_request          = ev_request.

        ENDIF.

      CATCH cx_badi_not_implemented.

        return-type       = 'E'.
        return-id         = 'ZEFATTURA'.
        return-number     = '062'.
        return-message_v1 = 'ZFATT_BADI_API'.

        RETURN.

    ENDTRY.

    IF ev_request IS INITIAL.

      return-type        = 'E'.
      return-id          = 'ZEFATTURA'.
      return-number      = '061'.
      return-message_v1  = 'ZFATT_BADI_API'.
      return-message_v2  = 'HANDLE_REQUEST_SEND_INVOICE'.

      RETURN.

    ENDIF.

    call_api( EXPORTING iv_request      = ev_request
              CHANGING  io_http_client  = zif_fatt_api~api_restull_send_invoice ).

* Gestione della risposta dell'API tramite BaDi
    IF zif_fatt_api~badi_fatt_api IS BOUND.

      CALL BADI zif_fatt_api~badi_fatt_api->handle_response_send_invoice
        EXPORTING
          io_http_response = zif_fatt_api~api_restull_send_invoice->response
        IMPORTING
          return           = return.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
