@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'rank sales'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZATS_AG_sales_rank
  as select from ZATS_AG_TF1    as rank
    inner join   zats_ag_bpa    as bpa on rank.company_name = bpa.company_name
    inner join   zats_ag_region as reg on bpa.region = reg.region
{
  key rank.company_name,
  rank.total_sales,
  rank.currency_code,
  rank.customer_rank,
  reg.regionname
}
