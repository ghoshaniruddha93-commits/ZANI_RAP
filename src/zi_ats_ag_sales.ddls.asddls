@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SALES CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ATS_AG_SALES
  as select from zats_ag_so_hdr as header
  association [1..*] to zats_ag_so_item as _Items on $projection.OrderId = _Items.order_id
{
  key header.order_id   as OrderId,
      header.order_no   as OrderNo,
      header.buyer      as Buyer,
      header.created_by as CreatedBy,
      header.created_on as CreatedOn,
      _Items
}
