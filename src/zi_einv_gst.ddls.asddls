@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Place GST Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_einv_gst
  as select from    I_IN_BusinessPlaceTaxDetail as GST
    left outer join I_Address_2                 as Address on Address.AddressID = GST.AddressID
{
  key GST.BusinessPlace,

      GST.IN_GSTIdentificationNumber as GSTIN,

      Address.OrganizationName1,
      Address.OrganizationName2,
      Address.StreetName,
      Address.CityName,
      Address.PostalCode,
      Address.Region
}
