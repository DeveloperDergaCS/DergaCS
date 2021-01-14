FUNCTION-POOL zefatt_utils.                 "MESSAGE-ID ..

TYPE-POOLS: ixml.

DATA: html_viewer     TYPE REF TO cl_gui_html_viewer,
      html_container  TYPE REF TO cl_gui_custom_container,
      type(20),
      subtype(20).

FIELD-SYMBOLS: <html_table> TYPE STANDARD TABLE.
