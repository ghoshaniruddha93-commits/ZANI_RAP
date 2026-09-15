CLASS zats_ag_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: lv_oper TYPE c VALUE 'D'.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zats_ag_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    CASE lv_oper.
      WHEN 'R'.
        READ ENTITIES OF zats_ag_travel
        ENTITY Travel
        FIELDS ( TravelId AgencyId CustomerId TotalPrice OverallStatus CreatedBy CreatedAt ) WITH
        VALUE #( ( TravelId = '00000004' )
                 ( TravelId = '00000005' )
               )
        RESULT DATA(lt_result)
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_message).

        out->write(
          EXPORTING
            data   = lt_result
        ).

        out->write(
          EXPORTING
            data   = lt_failed
        ).

        out->write(
          EXPORTING
            data   = lt_message
        ).
      WHEN 'U'.
        MODIFY ENTITIES OF zats_ag_travel
        ENTITY travel
        UPDATE
        FIELDS ( OverallStatus )
        WITH VALUE #( ( TravelId = '00000005'
                        OverallStatus = 'A'
                      )
                    )
        MAPPED DATA(lt_mapped)
        FAILED lt_failed
        REPORTED lt_message.

        COMMIT ENTITIES.

        out->write(
          EXPORTING
             data   = lt_mapped
        ).

        out->write(
          EXPORTING
            data   = lt_failed
        ).

        out->write(
          EXPORTING
            data   = lt_message
        ).
      WHEN 'C'.

        MODIFY ENTITIES OF zats_ag_travel
        ENTITY Travel
        CREATE AUTO FILL CID FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice BeginDate EndDate OverallStatus )
        WITH VALUE #( ( "%cid = 'a1'
                        TravelId = '00017755'
                        AgencyId = '070049'
                        CustomerId = '000072'
                        BookingFee = '120.00'
                        TotalPrice = '5584.50'
                        BeginDate  = cl_abap_context_info=>get_system_date(  )
                        EndDate    = cl_abap_context_info=>get_system_date(  )
                        OverallStatus = 'N'
                      )
                      ( "%cid = 'a2'
                        TravelId = '00017756'
                        AgencyId = '070032'
                        CustomerId = '000115'
                        BookingFee = '150.00'
                        TotalPrice = '5599.50'
                        BeginDate  = cl_abap_context_info=>get_system_date(  )
                        EndDate    = cl_abap_context_info=>get_system_date(  )
                        OverallStatus = 'N'
                      )
                    )
        MAPPED lt_mapped
        FAILED lt_failed
        REPORTED lt_message.

        COMMIT ENTITIES.

        out->write(
         EXPORTING
             data   = lt_mapped
        ).

        out->write(
          EXPORTING
            data   = lt_failed
        ).

        out->write(
          EXPORTING
            data   = lt_message
        ).
      WHEN 'D'.

        MODIFY ENTITIES OF zats_ag_travel
        ENTITY Travel
        DELETE FROM VALUE #( ( TravelId = '00017755' )
                             ( TravelId = '00017756' )
                           )
        MAPPED lt_mapped
        FAILED lt_failed
        REPORTED lt_message.

        COMMIT ENTITIES.

        out->write(
         EXPORTING
             data   = lt_mapped
        ).

        out->write(
          EXPORTING
            data   = lt_failed
        ).

        out->write(
          EXPORTING
            data   = lt_message
        ).


    ENDCASE.
  ENDMETHOD.
ENDCLASS.
