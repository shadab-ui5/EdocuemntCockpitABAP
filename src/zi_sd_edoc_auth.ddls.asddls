@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Doc Cockpit Auth'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_SD_EDOC_AUTH
  as select from zsdredocrole
{
  key userid       as Userid,
  key compcode     as Compcode,
  key salesorg     as SalesOrg,
  key plant        as Plant,
  key type         as Type,
      compname     as Compname,
      salesorgname as Salesorgname,
      plantname    as Plantname

}
