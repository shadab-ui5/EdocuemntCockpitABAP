@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice Ship-To Partner'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EINV_PARTNER
  //  as select from    I_BillingDocumentPartner as Partner
  as select from    I_Customer  as Customer

  //    left outer join I_Customer               as Customer on Customer.Customer = Partner.Customer

    left outer join I_Address_2 as Address on Address.AddressID = Customer.AddressID

{
        //  key Partner.BillingDocument,
        //  key Partner.PartnerFunction,

  key   Customer.Customer,

        Customer.TaxNumber3       as ShipToGSTIN,

        Address.OrganizationName1 as ShipToName1,
        Address.OrganizationName2 as ShipToName2,
        Address.StreetName        as ShipToStreet,
        Address.CityName          as ShipToCity,
        Address.PostalCode        as ShipToPostalCode,
        Address.Region            as ShipToRegion

}
//where
//  Partner.PartnerFunction = 'WE'
