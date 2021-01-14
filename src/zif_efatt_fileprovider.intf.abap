*"* components of interface ZIF_EFATT_FILEPROVIDER
interface ZIF_EFATT_FILEPROVIDER
  public .

  type-pools ABAP .

  methods GET_FILE_LISTING
    exporting
      value(ET_FILES) type ZEFATT_FILEDESCRIPTOR_T
      value(RETURN) type BAPIRET2 .
  methods SET_WORK_DIRECTORY
    importing
      value(BUKRS) type BUKRS
      value(INTERFACCIA) type ZEFATT_INTERFACCIA
    exporting
      value(RETURN) type BAPIRET2 .
  methods READ_FILE
    importing
      value(I_FILENAME) type STRING
    exporting
      value(ET_CONTENT) type SDOKCNTBINS
      value(E_SIZE) type I
      value(RETURN) type BAPIRET2 .
  methods WRITE_FILE
    importing
      value(I_FILENAME) type STRING
      value(I_FILESIZE) type I
      value(IT_CONTENT) type SDOKCNTBINS
    exporting
      value(RETURN) type BAPIRET2 .
  methods DELETE_FILE
    importing
      value(I_FILENAME) type STRING
    exporting
      value(RETURN) type BAPIRET2 .
  methods CLOSE
    importing
      value(I_FILENAME) type STRING
    exporting
      value(RETURN) type BAPIRET2 .
  methods TRANSFER_FILE
    importing
      value(I_FILENAME) type STRING
    exporting
      value(RETURN) type BAPIRET2 .
endinterface.
