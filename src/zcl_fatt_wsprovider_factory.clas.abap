class ZCL_FATT_WSPROVIDER_FACTORY definition
  public
  final
  create public .

public section.

  class-methods GET_WSPROVIDER
    importing
      !INTERFACCIA type ZEFATT_INTERFACCIA
      !I_TYPE type ZEFATT_INTERFACE_TIPO
    exporting
      value(RP_WSPROVIDER) type ref to ZIF_FATT_API
      value(RETURN) type BAPIRET2 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FATT_WSPROVIDER_FACTORY IMPLEMENTATION.


  METHOD get_wsprovider.

    DATA: lcl_rest TYPE REF TO zcl_fatt_rest_api,
          lcl_soap TYPE REF TO zcl_fatt_soap_api.

    CASE i_type.

      WHEN 'R'. " Web Service RestFull

        SELECT SINGLE COUNT(*) FROM zefatt_conf_rest
               WHERE interfaccia = interfaccia
               AND   active      = 'X'.

        IF sy-subrc <> 0.

          return-id         = 'ZEFATTURA'.
          return-type       = 'E'.
          return-number     = '054'.

          RETURN.

        ENDIF.

        CREATE OBJECT lcl_rest.

        rp_wsprovider = lcl_rest.

      WHEN 'S'. " Web Service SOAP

        CREATE OBJECT lcl_soap.

        rp_wsprovider = lcl_soap.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
