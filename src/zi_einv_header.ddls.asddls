@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice Header Data - Billing header + seller + buyer'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_EINV_HEADER
  as select from    I_BillingDocument        as Billing

    inner join      I_BillingDocumentPartner as Partner  on  Partner.BillingDocument = Billing.BillingDocument
                                                         and Partner.PartnerFunction = 'RE'

    left outer join I_Customer               as Customer on Customer.Customer = Partner.Customer

    left outer join I_Address_2              as Address  on Address.AddressID = Partner.AddressID

{
  key Billing.BillingDocument,

      Billing.BillingDocumentType,
      Billing.BillingDocumentDate,
      Billing.CompanyCode,
      Billing.SalesOrganization,
      Billing.DistributionChannel,
      Billing.Division,
      Billing.TransactionCurrency,
      Billing.SDDocumentCategory,
      Billing.BillingDocumentCategory,
      Billing.PurchaseOrderByCustomer,
      Billing.DocumentReferenceID,
      Billing.AssignmentReference,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Billing.TotalNetAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Billing.TotalTaxAmount,

      Partner.Customer          as BuyerCustomer,

      Customer.TaxNumber3       as BuyerGSTIN,

      Address.OrganizationName1 as BuyerName1,
      Address.OrganizationName2 as BuyerName2,
      Address.StreetName        as BuyerStreet,
      Address.CityName          as BuyerCity,
      Address.PostalCode        as BuyerPostalCode,
      Address.Region            as BuyerRegion

}
