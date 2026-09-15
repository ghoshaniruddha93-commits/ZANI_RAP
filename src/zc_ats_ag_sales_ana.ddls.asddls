@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SALES CONSUMPTION VIEW'
@Metadata.ignorePropagatedAnnotations: false
@Analytics.query: true
define view entity ZC_ATS_AG_SALES_ANA
  as select from ZI_ATS_AG_SALES_CUBE
{
      @AnalyticsDetails.query.axis: #ROWS
  key _BP.CompanyName,
      @AnalyticsDetails.query.axis: #ROWS
      _BP.CountryName,
      @AnalyticsDetails.query.axis: #COLUMNS
      Gross_amount,
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter.selectionType: #SINGLE
      CurrencyCode,
      @AnalyticsDetails.query.axis: #COLUMNS
      Quantity,
      @AnalyticsDetails.query.axis: #ROWS
      UnitofMeasure
}
