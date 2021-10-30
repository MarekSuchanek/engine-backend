module Shared.Database.DAO.Package.PackageDAO where

import Control.Lens ((^.))
import Control.Monad.Except (MonadError)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Logger (MonadLogger)
import Control.Monad.Reader (MonadReader, asks)
import Data.String (fromString)
import qualified Data.UUID as U
import Database.PostgreSQL.Simple
import GHC.Int

import Shared.Database.DAO.Common
import Shared.Database.Mapping.Package.Package ()
import Shared.Database.Mapping.Package.PackageWithEvents ()
import Shared.Database.Mapping.Package.PackageWithEventsRaw ()
import Shared.Model.Context.ContextLenses
import Shared.Model.Error.Error
import Shared.Model.Package.Package
import Shared.Model.Package.PackageWithEvents
import Shared.Model.Package.PackageWithEventsRaw
import Shared.Util.Logger

entityName = "package"

findPackages ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m) => m [Package]
findPackages = do
  appUuid <- asks (^. appUuid')
  createFindEntitiesByFn entityName [appQueryUuid appUuid]

findPackageWithEvents ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => m [PackageWithEvents]
findPackageWithEvents = do
  appUuid <- asks (^. appUuid')
  createFindEntitiesByFn entityName [appQueryUuid appUuid]

findPackageWithEventsRawById ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m PackageWithEventsRaw
findPackageWithEventsRawById id = do
  appUuid <- asks (^. appUuid')
  createFindEntityByFn entityName [appQueryUuid appUuid, ("id", id)]

findPackagesFiltered ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => [(String, String)]
  -> m [Package]
findPackagesFiltered queryParams = do
  appUuid <- asks (^. appUuid')
  createFindEntitiesByFn entityName (appQueryUuid appUuid : queryParams)

findPackagesByOrganizationIdAndKmId ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> String
  -> m [Package]
findPackagesByOrganizationIdAndKmId organizationId kmId = do
  appUuid <- asks (^. appUuid')
  createFindEntitiesByFn entityName [appQueryUuid appUuid, ("organization_id", organizationId), ("km_id", kmId)]

findPackagesByPreviousPackageId ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m [Package]
findPackagesByPreviousPackageId previousPackageId = do
  appUuid <- asks (^. appUuid')
  createFindEntitiesByFn entityName [appQueryUuid appUuid, ("previous_package_id", previousPackageId)]

findPackagesByForkOfPackageId ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m [Package]
findPackagesByForkOfPackageId forkOfPackageId = do
  appUuid <- asks (^. appUuid')
  createFindEntitiesByFn entityName [appQueryUuid appUuid, ("fork_of_package_id", forkOfPackageId)]

findVersionsForPackage ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> String
  -> m [String]
findVersionsForPackage orgId kmId = do
  appUuid <- asks (^. appUuid')
  let sql = "SELECT version FROM package WHERE app_uuid = ? and organization_id = ? and km_id = ?"
  logInfo _CMP_DATABASE sql
  let action conn = query conn (fromString sql) [U.toString appUuid, orgId, kmId]
  versions <- runDB action
  return . fmap fromOnly $ versions

findPackageById ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m Package
findPackageById id = do
  appUuid <- asks (^. appUuid')
  createFindEntityByFn entityName [appQueryUuid appUuid, ("id", id)]

findPackageById' ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m (Maybe Package)
findPackageById' id = do
  appUuid <- asks (^. appUuid')
  createFindEntityByFn' entityName [appQueryUuid appUuid, ("id", id)]

findPackageWithEventsById ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m PackageWithEvents
findPackageWithEventsById id = do
  appUuid <- asks (^. appUuid')
  createFindEntityByFn entityName [appQueryUuid appUuid, ("id", id)]

countPackages ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m) => m Int
countPackages = do
  appUuid <- asks (^. appUuid')
  createCountByFn entityName appCondition [appUuid]

insertPackage ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => PackageWithEvents
  -> m Int64
insertPackage = createInsertFn entityName

deletePackages ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m) => m Int64
deletePackages = createDeleteEntitiesFn entityName

deletePackagesFiltered ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => [(String, String)]
  -> m Int64
deletePackagesFiltered queryParams = do
  appUuid <- asks (^. appUuid')
  createDeleteEntitiesByFn entityName (appQueryUuid appUuid : queryParams)

deletePackageById ::
     (MonadLogger m, MonadError AppError m, MonadReader s m, HasDbPool' s, HasAppUuid' s, MonadIO m)
  => String
  -> m Int64
deletePackageById id = do
  appUuid <- asks (^. appUuid')
  createDeleteEntityByFn entityName [appQueryUuid appUuid, ("id", id)]
