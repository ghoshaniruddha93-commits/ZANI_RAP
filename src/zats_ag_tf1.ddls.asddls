@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE

define table function ZATS_AG_TF1
returns {
  client        : abap.clnt;
  company_name  : abap.char(256);
  total_sales   : abap.dec(15,2);
  currency_code : abap.cuky;
  customer_rank : abap.int4;
}
implemented by method zcl_ats_ag_tf=>get_total_sales;