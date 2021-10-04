module Wizard.Service.Admin.AdminDefinition where

import Control.Lens ((^.))

import LensesConfig hiding (action, cache, feedback)
import Wizard.Api.Resource.Admin.AdminExecutionDTO
import Wizard.Model.Admin.Admin
import Wizard.Model.Context.AppContext
import Wizard.Service.Cache.CacheService
import qualified Wizard.Service.Cache.KnowledgeModelCache as KnowledgeModelCache
import Wizard.Service.Feedback.FeedbackService

-- ---------------------------------------------------------------------------------------------------------------------
-- CACHE
-- ---------------------------------------------------------------------------------------------------------------------
cache :: AdminSection
cache =
  AdminSection
    { _adminSectionName = "Cache"
    , _adminSectionDescription = Nothing
    , _adminSectionOperations = [cache_purgeCache, cache_KnowledgeModelCache_deleteFromCache']
    }

-- ---------------------------------------------------------------------------------------------------------------------
cache_purgeCache :: AdminOperation
cache_purgeCache =
  AdminOperation
    {_adminOperationName = "purgeCache", _adminOperationDescription = Nothing, _adminOperationParameters = []}

cache_purgeCacheFn :: AdminExecutionDTO -> AppContextM String
cache_purgeCacheFn reqDto = do
  purgeCache
  return "Done"

-- ---------------------------------------------------------------------------------------------------------------------
cache_KnowledgeModelCache_deleteFromCache' :: AdminOperation
cache_KnowledgeModelCache_deleteFromCache' =
  AdminOperation
    { _adminOperationName = "KnowledgeModelCache.deleteFromCache'"
    , _adminOperationDescription = Nothing
    , _adminOperationParameters =
        [ AdminOperationParameter
            {_adminOperationParameterName = "pkgId", _adminOperationParameterAType = StringAdminOperationParameterType}
        ]
    }

cache_KnowledgeModelCache_deleteFromCacheFn' :: AdminExecutionDTO -> AppContextM String
cache_KnowledgeModelCache_deleteFromCacheFn' reqDto = do
  KnowledgeModelCache.deleteFromCache' (head (reqDto ^. parameters))
  return "Done"

-- ---------------------------------------------------------------------------------------------------------------------
-- FEEDBACK
-- ---------------------------------------------------------------------------------------------------------------------
feedback :: AdminSection
feedback =
  AdminSection
    { _adminSectionName = "Feedback"
    , _adminSectionDescription = Nothing
    , _adminSectionOperations = [feedback_synchronizeFeedbacks]
    }

-- ---------------------------------------------------------------------------------------------------------------------
feedback_synchronizeFeedbacks :: AdminOperation
feedback_synchronizeFeedbacks =
  AdminOperation
    {_adminOperationName = "synchronizeFeedbacks", _adminOperationDescription = Nothing, _adminOperationParameters = []}

feedback_synchronizeFeedbacksFn :: AdminExecutionDTO -> AppContextM String
feedback_synchronizeFeedbacksFn reqDto = do
  synchronizeFeedbacks
  return "Done"
