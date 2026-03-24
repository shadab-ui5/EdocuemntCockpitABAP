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

      Billing.BillingDocumentType        as BillingType,

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
      Billing.SoldToParty                as Customer,

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
      Billing.DocumentReferenceID,

      Billing.YY1_Transactiontype_BDH    as TransactionType,
      Billing.YY1_TransporterDe1_BDH     as Transporterid,
      Billing.YY1_TransporterDe2_BDH     as Transportername,
      Billing.YY1_ModeofTransport_BDH    as Transportmode,
      Billing.YY1_TransporterDocumen_BDH as Transdocno,
      Billing.YY1_TransporterDocDate_BDH as Transdocdate,
      Billing.YY1_VehicleType_BDH        as Vehicletype,
      Billing.YY1_RouteID25_BDH          as Transdistance,
      Billing.YY1_VehicleNumber_BDH      as Vehicleno,
      Billing.YY1_TransporterDe3_BDH     as Transportergstin,

      Billing.YY1_Port_DetailsName_BDH   as PortName,
      Billing.YY1_Port_DetailsState_BDH  as PortStateCode,
      Billing.YY1_Port_DetailsPin_BDH    as PortPin,
      Billing.YY1_Port_DetailsADRES_BDH  as PortAddress,
      Billing.YY1_Port_DetailsSName_BDH  as PortLocation,
      Billing.YY1_Port_DetailsCode_BDH   as PortCode,

      Billing.YY1_Date_BDH               as ShippingDate

}
where
  Billing.BillingDocumentIsCancelled <> 'X'
