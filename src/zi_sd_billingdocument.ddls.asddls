@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Billing Document'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SD_BillingDocument
  as select from    I_BillingDocument   as Billing
    left outer join ZI_BillDocItemPlant as ItemPlant on Billing.BillingDocument = ItemPlant.BillingDocument
    inner join      I_Customer          as Customer  on Billing.SoldToParty = Customer.Customer
{

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'ZI_SD_BillingDocument', element: 'BillingDocument' }
      }]
  key Billing.BillingDocument,

      Billing.BillingDocumentType as BillingType,

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_CompanyCode', element: 'CompanyCode' }
      }]
      Billing.CompanyCode,

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_SalesOrganizationText', element: 'SalesOrganization' }
      }]
      Billing.SalesOrganization,

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_DistributionChannelText', element: 'DistributionChannel' }
      }]
      Billing.DistributionChannel,

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_DivisionText', element: 'Division' }
      }]
      Billing.Division,

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_Customer', element: 'Customer' }
      }]
      Billing.SoldToParty         as Customer,

      Customer.CustomerName,

      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_Customer', element: 'Customer' }
      }]
      Billing.PayerParty,



      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'I_Plant', element: 'Plant' }
      }]
      ItemPlant.Plant,

      Billing.CreatedByUser,
      Billing.CreationDate,
      Billing.BillingDocumentDate,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Billing.TotalNetAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Billing.TotalTaxAmount,
      Billing.TransactionCurrency,

      Billing.Region,

      Billing.PurchaseOrderByCustomer,
      Billing.AssignmentReference,
      Billing.AccountingDocument,
      Billing.DocumentReferenceID

}
where
  Billing.BillingDocumentIsCancelled <> 'X'
