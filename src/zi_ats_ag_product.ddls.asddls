@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PRODUCT CDS INTERFACE VIEW'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ATS_AG_PRODUCT
  as select from zats_ag_product
{
  key product_id as ProductId,
      name       as Name,
      ctegory    as Ctegory,
      @Semantics.amount.currencyCode: 'currency'
      price      as Price,
      currency   as Currency,
      discount   as Discount
}
