@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Document Process Status Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EDOC_STATUS_VH
  as select from I_Language as lang
{
  key cast('EINVOICE_GENERATED'         as abap.char(30))  as ProcessStatus,
      cast('E-Invoice Generated'         as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('EINVOICE_FAILED'         as abap.char(30))             as ProcessStatus,
      cast('E-Invoice Generation Failed'         as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('EINVOICE_CANCELLED'         as abap.char(30))  as ProcessStatus,
      cast('E-Invoice Cancelled'         as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('CANCEL_EINVOICE_FAILED'         as abap.char(30))      as ProcessStatus,
      cast('E-Invoice Cancellion Failed'         as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('EWAY_GENERATED'             as abap.char(30))  as ProcessStatus,
      cast('E-Way Bill Generated'        as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('EWAY_CANCELLED'             as abap.char(30))  as ProcessStatus,
      cast('E-Way Bill Cancelled'        as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'

union all select from I_Language as lang
{
  key cast('EINVOICE_EWAY_GENERATED'    as abap.char(30))  as ProcessStatus,
      cast('E-Invoice + E-Way Generated' as abap.char(50)) as StatusDescription
}
where
  lang.Language = 'E'
