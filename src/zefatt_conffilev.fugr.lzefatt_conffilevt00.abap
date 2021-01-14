*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.06.2020 at 18:55:21 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_CONFFILEV................................*
TABLES: ZEFATT_CONFFILEV, *ZEFATT_CONFFILEV. "view work areas
CONTROLS: TCTRL_ZEFATT_CONFFILEV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_CONFFILEV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_CONFFILEV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_CONFFILEV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONFFILEV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONFFILEV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_CONFFILEV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONFFILEV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONFFILEV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_CONF_FILE               .
