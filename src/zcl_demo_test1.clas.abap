CLASS zcl_demo_test1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_demo_test1 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    out->write( 'My First Output in AoC' ).
  ENDMETHOD.
ENDCLASS.
