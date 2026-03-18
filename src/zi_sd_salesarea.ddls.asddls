@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Area'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SD_SalesArea
  as select distinct from I_SalesArea               as sa

    left outer join       I_DistributionChannelText as dct on  dct.DistributionChannel = sa.DistributionChannel
                                                           and dct.Language            = 'E'
                                                           
{

  key sa.SalesOrganization,
  key sa.DistributionChannel,

      dct.DistributionChannelName

}

group by
  sa.SalesOrganization,
  sa.DistributionChannel,
  dct.DistributionChannelName
