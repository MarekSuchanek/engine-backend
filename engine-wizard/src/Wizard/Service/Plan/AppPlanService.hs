module Wizard.Service.Plan.AppPlanService where

import Control.Monad (void, when)
import Control.Monad.Reader (asks, liftIO)
import Data.Foldable (traverse_)
import Data.Maybe (isJust)
import Data.Time
import qualified Data.UUID as U
import Prelude hiding (until)

import Shared.Util.List
import Shared.Util.Uuid
import Wizard.Api.Resource.Plan.AppPlanChangeDTO
import Wizard.Database.DAO.App.AppDAO
import Wizard.Database.DAO.Plan.AppPlanDAO
import Wizard.Model.App.App
import Wizard.Model.Config.AppConfig
import Wizard.Model.Context.AppContext
import Wizard.Model.Plan.AppPlan
import Wizard.Service.Acl.AclService
import Wizard.Service.Config.App.AppConfigService
import Wizard.Service.Limit.AppLimitService
import Wizard.Service.Plan.AppPlanMapper

getPlansForCurrentApp :: AppContextM [AppPlan]
getPlansForCurrentApp = do
  appUUid <- asks currentAppUuid
  findAppPlansForAppUuid appUUid

createPlan :: U.UUID -> AppPlanChangeDTO -> AppContextM AppPlan
createPlan aUuid reqDto = do
  checkPermission _APP_PERM
  app <- findAppByUuid aUuid
  uuid <- liftIO generateUuid
  now <- liftIO getCurrentTime
  let plan = fromChangeDTO reqDto uuid aUuid now now
  insertAppPlan plan
  recomputePlansForApp app
  return plan

modifyPlan :: U.UUID -> U.UUID -> AppPlanChangeDTO -> AppContextM AppPlan
modifyPlan aUuid pUuid reqDto = do
  checkPermission _APP_PERM
  app <- findAppByUuid aUuid
  plan <- findAppPlanByUuid pUuid
  let updatedPlan = fromChangeDTO reqDto plan.uuid plan.appUuid plan.createdAt plan.updatedAt
  updateAppPlanByUuid updatedPlan
  recomputePlansForApp app
  return updatedPlan

deletePlan :: U.UUID -> U.UUID -> AppContextM ()
deletePlan aUuid pUuid = do
  checkPermission _APP_PERM
  app <- findAppByUuid aUuid
  plan <- findAppPlanByUuid pUuid
  deleteAppPlanByUuid pUuid
  recomputePlansForApp app
  return ()

recomputePlansForApps :: AppContextM ()
recomputePlansForApps = do
  apps <- findApps
  traverse_ recomputePlansForApp apps

recomputePlansForApp :: App -> AppContextM ()
recomputePlansForApp app = do
  now <- liftIO getCurrentTime
  plans <- findAppPlansForAppUuid app.uuid
  let mActivePlan = headSafe . filter (isPlanActive now) $ plans
  -- Recompute active flag
  let active = isJust mActivePlan
  when (app.enabled /= active) (void $ updateAppByUuid (app {enabled = active}))
  -- Recompute features & limits
  case mActivePlan of
    Just activePlan -> do
      appConfig <- getAppConfigByUuid app.uuid
      let updatedAppConfig = turnTestPlanFeature activePlan.test appConfig
      when (appConfig.feature /= updatedAppConfig.feature) (void $ modifyAppConfig updatedAppConfig)
      recomputeAppLimit app.uuid activePlan.users
      return ()
    Nothing -> return ()

-- --------------------------------
-- PRIVATE
-- --------------------------------
isPlanActive :: UTCTime -> AppPlan -> Bool
isPlanActive now plan =
  case (plan.since, plan.until) of
    (Just since, Just until) -> since <= now && now <= until
    (Just since, Nothing) -> since <= now
    (Nothing, Just until) -> now <= until
    (Nothing, Nothing) -> True

turnTestPlanFeature :: Bool -> AppConfig -> AppConfig
turnTestPlanFeature enabled appConfig =
  appConfig
    { feature =
        appConfig.feature
          { pdfOnlyEnabled = enabled
          , pdfWatermarkEnabled = enabled
          }
    }
