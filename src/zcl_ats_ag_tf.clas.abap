CLASS zcl_ats_ag_tf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS get_total_sales FOR TABLE FUNCTION ZATS_AG_TF1.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ats_ag_tf IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.

  METHOD get_total_sales by DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
                       OPTIONS READ-ONLY
                       USING zats_ag_bpa zats_ag_so_hdr zats_ag_so_item.

    return select bpa.client,
                  bpa.company_name,
                  sum(item.amount) as Total_sales,
                  item.currency as Currency_code,
                  rank ( ) over (order by sum( item.amount ) desc) as Customer_rank
               from zats_ag_bpa as bpa
    inner join zats_ag_so_hdr as hdr on bpa.bp_id = hdr.buyer
    inner join zats_ag_so_item as item on hdr.order_id = item.order_id
    group by bpa.client,
             bpa.company_name,
             item.currency;

  ENDMETHOD.
ENDCLASS.
