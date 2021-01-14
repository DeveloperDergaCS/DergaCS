*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.06.2020 at 18:57:36 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_CONF_FTPV................................*
TABLES: ZEFATT_CONF_FTPV, *ZEFATT_CONF_FTPV. "view work areas
CONTROLS: TCTRL_ZEFATT_CONF_FTPV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_CONF_FTPV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_CONF_FTPV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_CONF_FTPV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONF_FTPV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONF_FTPV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_CONF_FTPV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONF_FTPV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONF_FTPV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_CONF_FTP                .
