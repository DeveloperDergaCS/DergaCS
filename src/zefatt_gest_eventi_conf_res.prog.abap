*&---------------------------------------------------------------------*
*&  Include           ZEFATT_GEST_EVENTI_CONF_RES
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include ZEFATT_GESTIONE_EVENTI_REG_CON
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  modify_fields_05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_fields_05.

  TABLES: zefatt_int_conf.

  SELECT SINGLE * FROM zefatt_int_conf
         WHERE interfaccia      = zefatt_conf_resv-interfaccia
         AND   interfaccia_tipo = 'R'.

  IF sy-subrc <> 0.
    MESSAGE e051(zefattura).
  ENDIF.

  IF  zefatt_conf_resv-rfc_login IS NOT INITIAL AND ( zefatt_conf_resv-utente    IS INITIAL OR
                                                       zefatt_conf_resv-password  IS INITIAL ).

    MESSAGE e060(zefattura).

  ENDIF.

ENDFORM.  " modify_fields
*&---------------------------------------------------------------------*
*&      Form  modify_fields_21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_fields_21.

  IF  zefatt_conf_resv-rfc_login IS NOT INITIAL AND ( zefatt_conf_resv-utente    IS INITIAL OR
                                                       zefatt_conf_resv-password  IS INITIAL ).

    MESSAGE e060(zefattura).

  ENDIF.

ENDFORM.  " modify_fields
