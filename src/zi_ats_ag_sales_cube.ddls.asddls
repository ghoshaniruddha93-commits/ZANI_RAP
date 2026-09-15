@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SALES COMPOSITE VIEW'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #CUBE
define view entity ZI_ATS_AG_SALES_CUBE
  as select from ZI_ATS_AG_SALES
  association [1] to ZI_ATS_AG_BPA     as _BP      on $projection.Buyer = _BP.BpId
  association [1] to ZI_ATS_AG_PRODUCT as _Product on $projection.Product = _Product.ProductId
{
  key ZI_ATS_AG_SALES.OrderId,
      ZI_ATS_AG_SALES.OrderNo,
      ZI_ATS_AG_SALES.Buyer,
      ZI_ATS_AG_SALES.CreatedBy,
      ZI_ATS_AG_SALES.CreatedOn,
      /* Associations */
      ZI_ATS_AG_SALES._Items.product  as Product,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'CurrencyCode'
      ZI_ATS_AG_SALES._Items.amount   as Gross_amount,
      ZI_ATS_AG_SALES._Items.currency as CurrencyCode,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'UnitofMeasure'
      ZI_ATS_AG_SALES._Items.qty      as Quantity,
      ZI_ATS_AG_SALES._Items.uom      as UnitofMeasure,
      _BP,
      _Product
}
