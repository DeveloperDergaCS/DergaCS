*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 11.07.2020 at 00:23:11 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_CONF_SOAV................................*
TABLES: ZEFATT_CONF_SOAV, *ZEFATT_CONF_SOAV. "view work areas
CONTROLS: TCTRL_ZEFATT_CONF_SOAV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_CONF_SOAV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_CONF_SOAV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_CONF_SOAV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONF_SOAV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONF_SOAV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_CONF_SOAV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONF_SOAV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONF_SOAV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_CONF_SOA                .
