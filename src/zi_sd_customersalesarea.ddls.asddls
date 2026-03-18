@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Custom based on sales area'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SD_CustomerSalesArea
  as select from I_CustomerSalesArea as custsa
    inner join   I_Customer          as cust on custsa.Customer = cust.Customer

{

  @Consumption.valueHelpDefinition: [
    { entity:  { name:    'ZI_SD_CustomerSalesArea',
                 element: 'Customer' }
    }]
  key custsa.Customer,
  key custsa.SalesOrganization,
  key custsa.DistributionChannel,
  key custsa.Division,

      cust.CustomerName,
      cust.CityName,
      cust.PostalCode,
      cust.StreetName,
      cust.Region,

      custsa.SalesOffice,
      custsa.SalesGroup,
      custsa.CustomerGroup,

      cust.VATRegistration,
      cust.TaxJurisdiction

}
