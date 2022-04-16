module Wizard.Service.Plan.AppPlanService where

import Control.Lens ((&), (.~), (^.))
import Control.Monad (void, when)
import Control.Monad.Reader (asks, liftIO)
import Data.Foldable (traverse_)
import Data.Time
import qualified Data.UUID as U
import Prelude hiding (until)

import LensesConfig
import Shared.Util.Uuid
import Wizard.Api.Resource.Plan.AppPlanChangeDTO
import Wizard.Database.DAO.App.AppDAO
import Wizard.Database.DAO.Plan.AppPlanDAO
import Wizard.Model.App.App
import Wizard.Model.Context.AppContext
import Wizard.Model.Plan.AppPlan
import Wizard.Service.Acl.AclService
import Wizard.Service.Plan.AppPlanMapper

getPlansForCurrentApp :: AppContextM [AppPlan]
getPlansForCurrentApp = do
  appUUid <- asks _appContextAppUuid
  findAppPlansForAppUuid (U.toString appUUid)

createPlan :: U.UUID -> AppPlanChangeDTO -> AppContextM AppPlan
createPlan aUuid reqDto = do
  checkPermission _APP_PERM
  app <- findAppById (U.toString aUuid)
  uuid <- liftIO generateUuid
  now <- liftIO getCurrentTime
  let plan = fromChangeDTO reqDto uuid aUuid now now
  insertAppPlan plan
  recomputePlansForApp app
  return plan

modifyPlan :: String -> String -> AppPlanChangeDTO -> AppContextM AppPlan
modifyPlan aUuid pUuid reqDto = do
  checkPermission _APP_PERM
  app <- findAppById aUuid
  plan <- findAppPlanById pUuid
  let updatedPlan = fromChangeDTO reqDto (plan ^. uuid) (plan ^. appUuid) (plan ^. createdAt) (plan ^. updatedAt)
  updateAppPlanById updatedPlan
  recomputePlansForApp app
  return updatedPlan

deletePlan :: String -> String -> AppContextM ()
deletePlan aUuid pUuid = do
  checkPermission _APP_PERM
  app <- findAppById aUuid
  plan <- findAppPlanById pUuid
  deleteAppPlanById pUuid
  recomputePlansForApp app
  return ()

recomputePlansForApps :: AppContextM ()
recomputePlansForApps = do
  apps <- findApps
  traverse_ recomputePlansForApp apps

recomputePlansForApp :: App -> AppContextM ()
recomputePlansForApp app = do
  now <- liftIO getCurrentTime
  plans <- findAppPlansForAppUuid (U.toString $ app ^. uuid)
  let active = foldl (\acc plan -> acc || isPlanActive now plan) False plans
  when (app ^. enabled /= active) (void $ updateAppById (app & enabled .~ active))

-- --------------------------------
-- PRIVATE
-- --------------------------------
isPlanActive :: UTCTime -> AppPlan -> Bool
isPlanActive now plan = plan ^. since <= now && now <= plan ^. until