@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Division'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SD_SalesDivision
  as select from    I_SalesArea    as sa

    left outer join I_DivisionText as dt on  dt.Division = sa.Division
                                         and dt.Language = 'E'
{

  key sa.SalesOrganization,
  key sa.Division,

      dt.DivisionName

}

group by
  sa.SalesOrganization,
  sa.Division,
  dt.DivisionName
