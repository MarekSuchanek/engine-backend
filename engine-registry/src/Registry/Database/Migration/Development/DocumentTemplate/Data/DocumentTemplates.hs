module Registry.Database.Migration.Development.DocumentTemplate.Data.DocumentTemplates where

import Registry.Api.Resource.DocumentTemplate.DocumentTemplateDetailDTO
import Registry.Api.Resource.DocumentTemplate.DocumentTemplateSimpleDTO
import Registry.Database.Migration.Development.Organization.Data.Organizations
import Registry.Service.DocumentTemplate.DocumentTemplateMapper
import Shared.Database.Migration.Development.DocumentTemplate.Data.DocumentTemplates

wizardDocumentTemplateSimpleDTO :: DocumentTemplateSimpleDTO
wizardDocumentTemplateSimpleDTO = toSimpleDTO [orgGlobal] wizardDocumentTemplate

wizardDocumentTemplateDetailDTO :: DocumentTemplateDetailDTO
wizardDocumentTemplateDetailDTO = toDetailDTO wizardDocumentTemplate ["1.0.0"] orgGlobal
