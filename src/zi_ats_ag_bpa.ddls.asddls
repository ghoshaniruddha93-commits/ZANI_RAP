@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BUSINESS PARTNER CDS INTERFACE'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ATS_AG_BPA
  as select from zats_ag_bpa
  association[1] to I_Country as _Country on
  $projection.Country = _Country.Country
{
  key bp_id        as BpId,
      bp_role      as BpRole,
      company_name as CompanyName,
      street       as Street,
      country      as Country,
      region       as Region,
      city         as City,
      _Country._Text[Language = $session.system_language].CountryName as CountryName
}
