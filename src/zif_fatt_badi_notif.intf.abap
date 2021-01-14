*"* components of interface ZIF_FATT_BADI_NOTIF
interface ZIF_FATT_BADI_NOTIF
  public .


  interfaces IF_BADI_INTERFACE .

  methods HANDLE_NOTIF
    importing
      !NOTIFICA type ZFATT_NOTIF_MAP .
endinterface.
