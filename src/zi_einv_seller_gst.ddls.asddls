@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_IN_BusinessPlaceTaxDetail'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EINV_SELLER_GST
  as select from    I_IN_BusinessPlaceTaxDetail as GST

    left outer join I_Address_2                 as Address on Address.AddressID = GST.AddressID

{
  key GST.BusinessPlace,

      GST.IN_GSTIdentificationNumber as SellerGSTIN,

      Address.OrganizationName1      as SellerName1,
      Address.OrganizationName2      as SellerName2,
      Address.StreetName             as SellerStreet,
      Address.CityName               as SellerCity,
      Address.PostalCode             as SellerPostalCode,
      Address.Region                 as SellerRegion

}
