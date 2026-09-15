CLASS zcl_for_vbap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_trv,
             travel_id   TYPE /dmo/travel_m-travel_id,
             total_price TYPE /dmo/travel_m-total_price,
           END OF ty_trv.
    CLASS-DATA: lt_travel TYPE TABLE OF ty_trv.
    INTERFACES if_oo_adt_classrun .
    CLASS-METHODS: get_vbak.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_for_vbap IMPLEMENTATION.


  METHOD get_vbak.
    SELECT travel_id, SUM( total_price ) AS total_price FROM /dmo/travel_m
    WHERE travel_id = '00000010'
    GROUP BY travel_id
    INTO TABLE @lt_travel.
    IF  sy-subrc = 0.
    ENDIF.
  ENDMETHOD.
  METHOD if_oo_adt_classrun~main.
    zcl_for_vbap=>get_vbak( ).
    out->write(
      EXPORTING
        data   = lt_travel
*        name   =
*      RECEIVING
*        output =
    ).
  ENDMETHOD.
ENDCLASS.
