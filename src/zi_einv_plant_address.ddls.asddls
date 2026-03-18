@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice Plant Dispatch Address'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EINV_PLANT_ADDRESS
  as select from    I_BillingDocumentItem as Item

    inner join      I_Plant               as Plant   on Plant.Plant = Item.Plant

    left outer join I_Address_2           as Address on Address.AddressID = Plant.AddressID

{

  key Item.BillingDocument,
  key Item.BillingDocumentItem,

      Item.Plant,
      Plant.BusinessPlace,

      // Dispatch Details for API

      Plant.PlantName           as DispatchName,
      Address.AddresseeFullName as Addr1,
      Address.StreetName        as Addr2,
      Address.CityName          as City,
      Address.PostalCode        as PostalCode,
      Address.Region            as StateCode

}
