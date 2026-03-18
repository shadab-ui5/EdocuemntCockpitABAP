@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Doc Overall Status Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EDOC_OVERALL_STATUS_VH
  as select from I_Language as lang
{
  key cast('PENDING'    as abap.char(10)) as OverallStatus,
      cast('Pending'    as abap.char(20)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('COMPLETED'  as abap.char(10)) as OverallStatus,
      cast('Completed'  as abap.char(20)) as StatusDescription
}
where
  lang.Language = 'E'
  
union all select from I_Language as lang
{
  key cast('CANCELLED'  as abap.char(10)) as OverallStatus,
      cast('Cancelled'  as abap.char(20)) as StatusDescription
}
where
  lang.Language = 'E'
  
union all select from I_Language as lang
{
  key cast('FAILED'  as abap.char(10)) as OverallStatus,
      cast('Failed'  as abap.char(20)) as StatusDescription
}
where
  lang.Language = 'E'
