*"* components of interface ZIF_EFATT_PROCESS_MAP
interface ZIF_EFATT_PROCESS_MAP
  public .


  methods PROCESS_MAP_INCOMING_INVOICE
    importing
      value(HEADER) type ZEFATT_HEADER_MAP
      value(BUDAT) type BKPF-BUDAT
      value(ITEM) type ZEFATT_ITEM_MAP_T
      value(ODA) type ZEFATT_ODA_MAP_T
      value(DDT) type ZEFATT_DDT_MAP_T
    exporting
      !ACCOUNTINGDATA type TAB_BAPI_INCINV_CREATE_ACCOUNT
      !GLACCOUNTDATA type ZBAPI_INCINV_CREATE_GL_ACCT_T
      value(HEADERDATA) type BAPI_INCINV_CREATE_HEADER
      value(ITEMDATA) type TAB_BAPI_INCINV_CREATE_ITEM
      value(RETURN) type BAPIRET2_T
      value(NO_REF) type FLAG .
  methods PROCESS_MAP_PARK_FI
    importing
      !HEADER type ZEFATT_HEADER_MAP
      !ITEM type ZEFATT_ITEM_MAP_T
      !CASSA type ZEFATT_CASSA_MAP_T
      !RITENUTA type ZEFATT_RITENUTA_MAP_T
      !BUDAT type BKPF-BUDAT optional
      !SDI_DATE type ZEFATT_SDI_DATE
    exporting
      !E_BKPF type BKPF_T
      !E_BSEG type BSEG_T
      !E_SPLTWT type WITH_TEM_TAB
      !RETURN type BAPIRET2_T .
endinterface.
