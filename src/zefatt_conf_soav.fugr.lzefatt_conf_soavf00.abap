*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 11.07.2020 at 00:23:11 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_CONF_SOAV................................*
FORM GET_DATA_ZEFATT_CONF_SOAV.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZEFATT_CONF_SOA WHERE
(VIM_WHERETAB) .
    CLEAR ZEFATT_CONF_SOAV .
ZEFATT_CONF_SOAV-MANDT =
ZEFATT_CONF_SOA-MANDT .
ZEFATT_CONF_SOAV-INTERFACCIA =
ZEFATT_CONF_SOA-INTERFACCIA .
ZEFATT_CONF_SOAV-SOA_SERVICE_NAME =
ZEFATT_CONF_SOA-SOA_SERVICE_NAME .
ZEFATT_CONF_SOAV-LOGICAL_PORT_NAM =
ZEFATT_CONF_SOA-LOGICAL_PORT_NAM .
ZEFATT_CONF_SOAV-CLASSNAME =
ZEFATT_CONF_SOA-CLASSNAME .
ZEFATT_CONF_SOAV-METHOD =
ZEFATT_CONF_SOA-METHOD .
ZEFATT_CONF_SOAV-ACTIVE =
ZEFATT_CONF_SOA-ACTIVE .
<VIM_TOTAL_STRUC> = ZEFATT_CONF_SOAV.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZEFATT_CONF_SOAV .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZEFATT_CONF_SOAV.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZEFATT_CONF_SOAV-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZEFATT_CONF_SOA WHERE
  INTERFACCIA = ZEFATT_CONF_SOAV-INTERFACCIA AND
  SOA_SERVICE_NAME = ZEFATT_CONF_SOAV-SOA_SERVICE_NAME .
    IF SY-SUBRC = 0.
    DELETE ZEFATT_CONF_SOA .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZEFATT_CONF_SOA WHERE
  INTERFACCIA = ZEFATT_CONF_SOAV-INTERFACCIA AND
  SOA_SERVICE_NAME = ZEFATT_CONF_SOAV-SOA_SERVICE_NAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZEFATT_CONF_SOA.
    ENDIF.
ZEFATT_CONF_SOA-MANDT =
ZEFATT_CONF_SOAV-MANDT .
ZEFATT_CONF_SOA-INTERFACCIA =
ZEFATT_CONF_SOAV-INTERFACCIA .
ZEFATT_CONF_SOA-SOA_SERVICE_NAME =
ZEFATT_CONF_SOAV-SOA_SERVICE_NAME .
ZEFATT_CONF_SOA-LOGICAL_PORT_NAM =
ZEFATT_CONF_SOAV-LOGICAL_PORT_NAM .
ZEFATT_CONF_SOA-CLASSNAME =
ZEFATT_CONF_SOAV-CLASSNAME .
ZEFATT_CONF_SOA-METHOD =
ZEFATT_CONF_SOAV-METHOD .
ZEFATT_CONF_SOA-ACTIVE =
ZEFATT_CONF_SOAV-ACTIVE .
    IF SY-SUBRC = 0.
    UPDATE ZEFATT_CONF_SOA .
    ELSE.
    INSERT ZEFATT_CONF_SOA .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZEFATT_CONF_SOAV-UPD_FLAG,
STATUS_ZEFATT_CONF_SOAV-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZEFATT_CONF_SOAV.
  SELECT SINGLE * FROM ZEFATT_CONF_SOA WHERE
INTERFACCIA = ZEFATT_CONF_SOAV-INTERFACCIA AND
SOA_SERVICE_NAME = ZEFATT_CONF_SOAV-SOA_SERVICE_NAME .
ZEFATT_CONF_SOAV-MANDT =
ZEFATT_CONF_SOA-MANDT .
ZEFATT_CONF_SOAV-INTERFACCIA =
ZEFATT_CONF_SOA-INTERFACCIA .
ZEFATT_CONF_SOAV-SOA_SERVICE_NAME =
ZEFATT_CONF_SOA-SOA_SERVICE_NAME .
ZEFATT_CONF_SOAV-LOGICAL_PORT_NAM =
ZEFATT_CONF_SOA-LOGICAL_PORT_NAM .
ZEFATT_CONF_SOAV-CLASSNAME =
ZEFATT_CONF_SOA-CLASSNAME .
ZEFATT_CONF_SOAV-METHOD =
ZEFATT_CONF_SOA-METHOD .
ZEFATT_CONF_SOAV-ACTIVE =
ZEFATT_CONF_SOA-ACTIVE .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZEFATT_CONF_SOAV USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZEFATT_CONF_SOAV-INTERFACCIA TO
ZEFATT_CONF_SOA-INTERFACCIA .
MOVE ZEFATT_CONF_SOAV-SOA_SERVICE_NAME TO
ZEFATT_CONF_SOA-SOA_SERVICE_NAME .
MOVE ZEFATT_CONF_SOAV-MANDT TO
ZEFATT_CONF_SOA-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZEFATT_CONF_SOA'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZEFATT_CONF_SOA TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZEFATT_CONF_SOA'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
