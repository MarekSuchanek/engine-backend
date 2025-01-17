module Wizard.Database.DAO.Limit.AppLimitDAO where

import Control.Monad.Reader (asks, liftIO)
import Data.String
import Data.Time
import qualified Data.UUID as U
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.ToField
import Database.PostgreSQL.Simple.ToRow
import GHC.Int

import Wizard.Database.DAO.Common
import Wizard.Database.Mapping.Limit.AppLimit ()
import Wizard.Model.Context.AppContext
import Wizard.Model.Context.ContextLenses ()
import Wizard.Model.Limit.AppLimit

entityName = "app_limit"

findAppLimits :: AppContextM [AppLimit]
findAppLimits = createFindEntitiesFn entityName

findAppLimitByUuid :: U.UUID -> AppContextM AppLimit
findAppLimitByUuid uuid = createFindEntityByFn entityName [("uuid", U.toString uuid)]

findCurrentAppLimit :: AppContextM AppLimit
findCurrentAppLimit = do
  appUuid <- asks currentAppUuid
  findAppLimitByUuid appUuid

insertAppLimit :: AppLimit -> AppContextM Int64
insertAppLimit = createInsertFn entityName

updateAppLimitByUuid :: AppLimit -> AppContextM AppLimit
updateAppLimitByUuid appLimit = do
  now <- liftIO getCurrentTime
  let updatedAppLimit = appLimit {updatedAt = now}
  let sql =
        fromString
          "UPDATE app_limit SET uuid = ?, users = ?, active_users = ?, knowledge_models = ?, branches = ?, document_templates = ?, questionnaires = ?, documents =?, storage = ?, created_at = ?, updated_at = ?, document_template_drafts = ?, locales = ? WHERE uuid = ?"
  let params = toRow updatedAppLimit ++ [toField updatedAppLimit.uuid]
  logQuery sql params
  let action conn = execute conn sql params
  runDB action
  return updatedAppLimit

deleteAppLimits :: AppContextM Int64
deleteAppLimits = createDeleteEntitiesFn entityName
