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
         WHERE interfaccia = zefatt_conffilev-interfaccia
         AND   interfaccia_tipo = 'A'.

  IF sy-subrc <> 0.
    MESSAGE e051(zefattura).
  ENDIF.

ENDFORM.  " modify_fields
