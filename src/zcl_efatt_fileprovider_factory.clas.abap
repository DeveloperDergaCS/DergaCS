*----------------------------------------------------------------------*
*       CLASS ZCL_EFATT_FILEPROVIDER_FACTORY  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_EFATT_FILEPROVIDER_FACTORY definition
  public
  final
  create private .

*"* public components of class ZCL_EFATT_FILEPROVIDER_FACTORY
*"* do not include other source files here!!!
public section.

  constants FTP type ZEFATT_INTERFACE_TIPO value 'F' ##NO_TEXT.
  constants FILE_LOGICO type ZEFATT_INTERFACE_TIPO value 'A' ##NO_TEXT.

  class-methods GET_FILEPROVIDER
    importing
      !BUKRS type BUKRS
      !INTERFACCIA type ZEFATT_INTERFACCIA
      value(I_TYPE) type ZEFATT_INTERFACE_TIPO
    exporting
      value(RP_FILEPROVIDER) type ref to ZIF_EFATT_FILEPROVIDER
      !RETURN type BAPIRET2 .
protected section.
*"* protected components of class ZCL_EFATT_FILEPROVIDER_FACTORY
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_EFATT_FILEPROVIDER_FACTORY
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_EFATT_FILEPROVIDER_FACTORY IMPLEMENTATION.


METHOD get_fileprovider .

  DATA: lp_ftp_provider  TYPE REF TO zcl_efatt_ftp_fileprovider,
        lp_file_provider TYPE REF TO zcl_efatt_file_fileprovider,
        i_server         TYPE	zefatt_host,
        i_user           TYPE zefatt_utente,
        i_password       TYPE zefatt_password,
        path             TYPE string,
        l_pw_len         TYPE i,
        l_pw_tmp(255).


  CASE i_type.

    WHEN ftp.

      SELECT SINGLE host utente password FROM zefatt_conf_ftp INTO (i_server, i_user, i_password)
             WHERE bukrs       = bukrs
             AND   interfaccia = interfaccia
             AND   active      = 'X'.

      IF sy-subrc <> 0.

        return-id         = 'ZEFATTURA'.
        return-type       = 'E'.
        return-number     = '046'.

        RETURN.

      ENDIF.

* Settare la password in un modo riconosciuto da SAP
      l_pw_len = strlen( i_password ).

      CALL FUNCTION 'HTTP_SCRAMBLE'
        EXPORTING
          source      = i_password
          sourcelen   = l_pw_len
          key         = 26101957
        IMPORTING
          destination = l_pw_tmp.

* Instazio oggetto FTP
      CREATE OBJECT lp_ftp_provider.

      CALL FUNCTION 'FTP_CONNECT'
        EXPORTING
          user            = i_user
          password        = l_pw_tmp
          host            = i_server
          rfc_destination = 'SAPFTPA'
        IMPORTING
          handle          = lp_ftp_provider->m_ftp_conn_id
        EXCEPTIONS
          not_connected   = 1
          OTHERS          = 2.

      IF sy-subrc <> 0.

        return-id         = sy-msgid.
        return-type       = sy-msgty.
        return-number     = sy-msgno.
        return-message_v1 = sy-msgv1.
        return-message_v2 = sy-msgv2.
        return-message_v3 = sy-msgv3.
        return-message_v4 = sy-msgv4.

        RETURN.

      ENDIF.

      rp_fileprovider = lp_ftp_provider.

    WHEN file_logico.

* Instazio oggetto per gestione FILE LOGICO
      CREATE OBJECT lp_file_provider.

      rp_fileprovider = lp_file_provider.

  ENDCASE.

ENDMETHOD.
ENDCLASS.
