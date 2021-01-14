class ZEFATT_CO_HTTP definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP1
    importing
      !INPUT type ZEFATT_MESSAGE1
    exporting
      !OUTPUT type ZEFATT_MESSAGE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP2
    importing
      !INPUT type ZEFATT_MESSAGE2
    exporting
      !OUTPUT type ZEFATT_MESSAGE2
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP3
    importing
      !INPUT type ZEFATT_MESSAGE3
    exporting
      !OUTPUT type ZEFATT_MESSAGE3
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP4
    importing
      !INPUT type ZEFATT_MESSAGE4
    exporting
      !OUTPUT type ZEFATT_MESSAGE4
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP5
    importing
      !INPUT type ZEFATT_MESSAGE5
    exporting
      !OUTPUT type ZEFATT_MESSAGE5
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP6
    importing
      !INPUT type ZEFATT_MESSAGE6
    exporting
      !OUTPUT type ZEFATT_MESSAGE6
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP7
    importing
      !INPUT type ZEFATT_MESSAGE7
    exporting
      !OUTPUT type ZEFATT_MESSAGE7
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP8
    importing
      !INPUT type ZEFATT_MESSAGE8
    exporting
      !OUTPUT type ZEFATT_MESSAGE8
    raising
      CX_AI_SYSTEM_FAULT .
  methods OP9
    importing
      !INPUT type ZEFATT_MESSAGE9
    exporting
      !OUTPUT type ZEFATT_MESSAGE9
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZEFATT_CO_HTTP IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZEFATT_CO_HTTP'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method OP1.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP1'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP3.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP3'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP4.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP4'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP5.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP5'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP6.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP6'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP7.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP7'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP8.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP8'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method OP9.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OP9'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
